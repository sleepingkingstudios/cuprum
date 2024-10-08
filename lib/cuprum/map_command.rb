# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Calls the command implementation with each item in the given enumerable.
  #
  # A regular Command is called with a set of parameters, calls the command
  # implementation once with those parameters, and returns the Result. In
  # contrast, a MapCommand is called with an Enumerable object, such as an
  # Array, a Hash, or an Enumerator (e.g. by calling #each without a block). The
  # MapCommand implementation is then called with each item in the
  # Enumerable - for example, if called with an Array with three items, the
  # MapCommand implementation would be called three times, once with each item.
  # Finally, the Results returned by calling the implementation with each item
  # are aggregated together into a Cuprum::ResultList. A ResultList behaves like
  # a Result, and provides the standard methods (such as #status, #error, and
  # #value), but also includes a reference to the #results used to create the
  # ResultList, and their respective #errors and #values as Arrays.
  #
  # Like a standard Command, a MapCommand can be defined either by passing a
  # block to the constructor, or by defining a subclass of MapCommand and
  # implementing the #process method. If the given block or the #process method
  # accepts more than one argument, the enumerable item is destructured using
  # the splat operator (*); this enables using a MapCommand to map over the keys
  # and values of a Hash. This is the same behavior seen when passing a block
  # with multiple arguments to a native #each method.
  #
  # If a MapCommand is initialized with the :allow_partial keyword, the
  # ResultList will be passing as long as there is at least one passing Result
  # (or if the MapCommand is called with an empty Enumerable). See
  # ResultList#allow_partial? for details.
  #
  # @example A MapCommand with a block
  #   titleize_command = Cuprum::MapCommand.new do |str|
  #     if str.nil? || str.empty?
  #       next failure(Cuprum::Error.new(message: "can't be blank"))
  #     end
  #
  #     str.split(' ').map(&:capitalize).join(' ')
  #   end
  #
  # @example A MapCommand Subclass
  #   class TitleizeCommand < Cuprum::MapCommand
  #     private
  #
  #     def process(str)
  #       if str.nil? || str.empty?
  #         return failure(Cuprum::Error.new(message: "can't be blank"))
  #       end
  #
  #       str.split(' ').map(&:capitalize).join(' ')
  #     end
  #   end
  #
  #   titleize_command = TitleizeCommand.new
  #
  # @example With an Array with passing Results
  #   results = titleize_command.call(['hello world', 'greetings programs'])
  #   results.class
  #   #=> Cuprum::ResultsList
  #   results.status
  #   #=> :success
  #   results.value
  #   #=> ['Hello World', 'Greetings Programs']
  #   results.values
  #   #=> ['Hello World', 'Greetings Programs']
  #   results.error
  #   #=> nil
  #   results.errors
  #   #=> [nil, nil]
  #
  # @example With an Array with failing Results
  #   results = titleize_command.call([nil, ''])
  #   results.status
  #   #=> :failure
  #   results.value
  #   #=> [nil, nil]
  #   results.values
  #   #=> [nil, nil]
  #   results.error.class
  #   #=> Cuprum::Errors::MultipleErrors
  #   results.errors.map(&:class)
  #   #=> [Cuprum::Error, Cuprum::Error]
  #   results.errors.first.message
  #   #=> "can't be blank"
  #
  # @example With an Array with mixed passing and failing Results
  #   results = titleize_command.call([nil, 'greetings programs'])
  #   results.status
  #   #=> :failure
  #   results.value
  #   #=> [nil, "Greetings Programs"]
  #   results.values
  #   #=> [nil, "Greetings Programs"]
  #   results.error.class
  #   #=> Cuprum::Errors::MultipleErrors
  #   results.errors.map(&:class)
  #   #=> [Cuprum::Error, nil]
  #   results.errors.first.message
  #   #=> "can't be blank"
  #
  # @example With an Empty Array
  #   results = titleize_command.call([])
  #   results.status
  #   #=> :success
  #   results.value
  #   #=> []
  #   results.values
  #   #=> []
  #   results.error
  #   #=> nil
  #   results.errors
  #   #=> []
  #
  # @example With a Hash
  #   inspect_command = Cuprum::MapCommand.new do |key, value|
  #     "#{key.inspect} => #{value.inspect}"
  #   end
  #
  #   results = inspect_command.call({ ichi: 1, "ni" => 2 })
  #   results.status
  #   #=> :success
  #   results.value
  #   #=> [':ichi => 1', '"ni" => 2']
  #   results.values
  #   #=> [':ichi => 1', '"ni" => 2']
  #   results.error
  #   #=> nil
  #   results.errors
  #   #=> [nil, nil]
  #
  # @example With an Enumerable
  #   square_command = Cuprum::MapCommand.new { |i| i ** 2 }
  #
  #   results = square_command.call(0...4)
  #   results.status
  #   #=> :success
  #   results.value
  #   #=> [0, 1, 4, 9]
  #   results.values
  #   #=> [0, 1, 4, 9]
  #
  # @example With allow_partial: true
  #   maybe_upcase_command = Cuprum::MapCommand.new do |str|
  #     next str.upcase if str.is_a?(String)
  #
  #     failure(Cuprum::Error.new(message: 'not a String'))
  #   end
  #
  #   results = maybe_upcase_command.call([nil, 'greetings', 'programs'])
  #   results.status
  #   #=> :success
  #   results.value
  #   #=> [nil, 'GREETINGS', 'PROGRAMS']
  #   results.values
  #   #=> [nil, 'GREETINGS', 'PROGRAMS']
  #   results.error.class
  #   #=> Cuprum::Errors::MultipleErrors
  #   results.errors.map(&:class)
  #   #=> [Cuprum::Error, nil, nil]
  #   results.errors.first.message
  #   #=> 'not a String'
  #
  # @see Cuprum::Command
  # @see Cuprum::ResultList
  class MapCommand < Cuprum::Command
    # @overload initialize(allow_partial: false)
    #   @param allow_partial [true, false] If true, allows for some failing
    #     results as long as there is at least one passing result. Defaults to
    #     false.
    #
    # @overload initialize(allow_partial: false) { |item| }
    #   @param allow_partial [true, false] If true, allows for some failing
    #     results as long as there is at least one passing result. Defaults to
    #     false.
    #   @yield The command implementation, to be called with each successive
    #     item in the given enumerable. This overrides the #process method, if
    #     any.
    #   @yieldparam [Object] item Each item in the given Enumerable.
    #
    # @overload initialize(allow_partial: false) { |key, value| }
    #   @param allow_partial [true, false] If true, allows for some failing
    #     results as long as there is at least one passing result. Defaults to
    #     false.
    #   @yield The command implementation, to be called with each successive
    #     item in the given enumerable. This overrides the #process method, if
    #     any.
    #   @yieldparam [Object] key Each key in the given Hash.
    #   @yieldparam [Object] value Each value in the given Hash.
    def initialize(allow_partial: false, &implementation)
      super(&implementation)

      @allow_partial = allow_partial
    end

    # @return [true, false] if true, allows for some failing results as long as
    #   there is at least one passing result. Defaults to false.
    def allow_partial?
      @allow_partial
    end

    # Calls the command implementation for each item in the given Enumerable.
    #
    # @param enumerable [Array, Hash, Enumerable] The collection or enumerable
    #   object to map.
    #
    # @return [Cuprum::ResultList] the aggregated results.
    def call(enumerable)
      build_result_list(
        enumerable.map { |item| splat_items? ? super(*item) : super(item) }
      )
    end

    private

    def build_result_list(results)
      Cuprum::ResultList.new(*results, allow_partial: allow_partial?)
    end

    def splat_items?
      return @splat_items unless @splat_items.nil?

      if respond_to?(:process_block, true)
        return @splat_items = method(:process_block).arity > 1
      end

      @splat_items = method(:process).arity > 1
    end
  end
end
