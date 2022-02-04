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
  #   results = titleize_command.call('hello world', 'greetings programs')
  #   results.class
  #   #=> Cuprum::ResultsList
  #   results.status
  #   #=> :succes
  #   results.value
  #   #=> ['Hello World', 'Greetings, Programs']
  #
  # @example With an Array with failing Results
  #   @todo
  #
  # @example With an Array with mixed passing and failing Results
  #   @todo
  #
  # @example With an Empty Array
  #   @todo
  #
  # @example With a Hash
  #   @todo
  #
  # @example With an Enumerable
  #   @todo
  #
  # @see Cuprum::Command
  # @see Cuprum::ResultList
  class MapCommand < Cuprum::Command
    # @overload initialize(allow_partial: false)
    #   @param allow_partial [true, false] If true, allows for some failing
    #     results as long as there is at least one passing result. Defaults to
    #     false.
    #
    # @overload initialize(allow_partial: false)
    #   @param allow_partial [true, false] If true, allows for some failing
    #     results as long as there is at least one passing result. Defaults to
    #     false.
    #   @yield The command implementation, to be called with each successive
    #     item in the given enumerable. This overrides the #process method, if
    #     any.
    #   @yieldparam [Object] item Each item in the given Enumerable.
    #
    # @overload initialize(allow_partial: false)
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
      results =
        enumerable.map { |item| splat_items? ? super(*item) : super(item) }

      Cuprum::ResultList.new(*results, allow_partial: allow_partial?)
    end

    private

    def splat_items?
      return @splat_items unless @splat_items.nil?

      @splat_items = method(:process).arity > 1
    end
  end
end
