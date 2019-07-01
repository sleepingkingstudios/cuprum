# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Mixin to implement command chaining functionality for a command class.
  # Chaining commands allows you to define complex logic by composing it from
  # simpler commands, including branching logic and error handling.
  #
  # @example Chaining Commands
  #   # By chaining commands together with the #chain instance method, we set up
  #   # a series of commands to run in sequence. Each chained command is passed
  #   # the value of the previous command.
  #
  #   class GenerateUrlCommand
  #     include Cuprum::Chaining
  #     include Cuprum::Processing
  #
  #     private
  #
  #     # Acts as a pipeline, taking a value (the title of the given post) and
  #     # calling the underscore, URL safe, and prepend date commands. By
  #     # passing parameters to PrependDateCommand, we can customize the command
  #     # in the pipeline to the current context (in this case, the Post).
  #     def process post
  #       UnderscoreCommand.new.
  #         chain(UrlSafeCommand.new).
  #         chain(PrependDateCommand.new(post.created_at)).
  #         call(post.title)
  #     end
  #   end
  #
  #   title = 'Greetings, programs!'
  #   date  = '1982-07-09'
  #   post  = Post.new(:title => title, :created_at => date)
  #   url   = GenerateUrlCommand.new.call(post).value
  #   #=> '1982_07_09_greetings_programs'
  #
  #   title = 'Plasma-based Einhanders in Popular Media'
  #   date  = '1977-05-25'
  #   post  = Post.new(:title => title, :created_at => date)
  #   url   = GenerateUrlCommand.new.call(post).value
  #   #=> '1977_05_25_plasma_based_einhanders_in_popular_media'
  #
  # @example Conditional Chaining
  #   # Commands can be conditionally chained based on the success or failure of
  #   # the previous command using the on: keyword. If the command is chained
  #   # using on: :success, it will only be called if the result is passing.
  #   # If the command is chained using on: :failure, it will only be called if
  #   # the command is failing. This can be used to perform error handling.
  #
  #   class CreateTaggingCommand
  #     include Cuprum::Chaining
  #     include Cuprum::Processing
  #
  #     private
  #
  #     # Tries to find the tag with the given name. If that fails, creates a
  #     # new tag with the given name. If the tag is found, or if the new tag is
  #     # successfully created, then creates a tagging using the tag. If the tag
  #     # is not found and cannot be created, then the tagging is not created
  #     # and the result of the CreateTaggingCommand is a failure with the
  #     # appropriate error messages.
  #     def process taggable, tag_name
  #       FindTag.new.call(tag_name).
  #         # The chained command is called with the value of the previous
  #         # command, in this case the Tag or nil returned by FindTag.
  #         chain(:on => :failure) do |tag|
  #           # Chained commands share a result object, including errors. To
  #           # rescue a command chain and return the execution to the "happy
  #           # path", use on: :failure and clear the errors.
  #           result.errors.clear
  #
  #           Tag.create(tag_name)
  #         end.
  #         chain(:on => :success) do |tag|
  #           tag.create_tagging(taggable)
  #         end
  #     end
  #   end
  #
  #   post        = Post.create(:title => 'Tagging Example')
  #   example_tag = Tag.create(:name => 'Example Tag')
  #
  #   result = CreateTaggingCommand.new.call(post, 'Example Tag')
  #   result.success? #=> true
  #   result.errors   #=> []
  #   result.value    #=> an instance of Tagging
  #   post.tags.map(&:name)
  #   #=> ['Example Tag']
  #
  #   result = CreateTaggingCommand.new.call(post, 'Another Tag')
  #   result.success? #=> true
  #   result.errors   #=> []
  #   result.value    #=> an instance of Tagging
  #   post.tags.map(&:name)
  #   #=> ['Example Tag', 'Another Tag']
  #
  #   result = CreateTaggingCommand.new.call(post, 'An Invalid Tag Name')
  #   result.success? #=> false
  #   result.errors   #=> [{ tag: { name: ['is invalid'] }}]
  #   post.tags.map(&:name)
  #   #=> ['Example Tag', 'Another Tag']
  #
  # @example Yield Result and Tap Result
  #   # The #yield_result method allows for advanced control over a step in the
  #   # command chain. The block will be yielded the result at that point in the
  #   # chain, and will wrap the returned value in a result to the next chained
  #   # command (or return it directly if the returned value is a result).
  #   #
  #   # The #tap_result method inserts arbitrary code into the command chain
  #   # without interrupting it. The block will be yielded the result at that
  #   # point in the chain and will pass that same result to the next chained
  #   # command after executing the block. The return value of the block is
  #   # ignored.
  #
  #   class UpdatePostCommand
  #     include Cuprum::Chaining
  #     include Cuprum::Processing
  #
  #     private
  #
  #     def process id, attributes
  #       # First, find the referenced post.
  #       Find.new(Post).call(id).
  #         yield_result(:on => :failure) do |result|
  #           redirect_to posts_path
  #
  #           # A halted result prevents further :on => :failure commands from
  #           # being called.
  #           result.halt!
  #         end.
  #         yield_result do |result|
  #           # Assign our attributes and save the post.
  #           UpdateAttributes.new.call(result.value, attributes)
  #         end.
  #         tap_result(:on => :success) do |result|
  #           # Create our tags, but still return the result of our update.
  #           attributes[:tags].each do |tag_name|
  #             CreateTaggingCommand.new.call(result.value, tag_name)
  #           end
  #         end.
  #         tap_result(:on => :always) do |result|
  #           # Chaining :on => :always ensures that the command will be run,
  #           # even if the previous result is failing or halted.
  #           if result.failure?
  #             log_errors(
  #               :command => UpdatePostCommand,
  #               :errors => result.errors
  #             )
  #           end
  #         end
  #     end
  #   end
  #
  # @example Protected Chaining Methods
  #   # Using the protected chaining methods #chain!, #tap_result!, and
  #   # #yield_result!, you can create a command class that composes other
  #   # commands.
  #
  #   # We subclass the build command, which will be executed first.
  #   class CreateCommentCommand < BuildCommentCommand
  #     include Cuprum::Chaining
  #     include Cuprum::Processing
  #
  #     def initialize
  #       # After the build step is run, we validate the comment.
  #       chain!(ValidateCommentCommand.new)
  #
  #       # If the validation passes, we then save the comment.
  #       chain!(SaveCommentCommand.new, on: :success)
  #     end
  #   end
  #
  # @see Cuprum::Command
  module Chaining
    # Creates a copy of the first command, and then chains the given command or
    # block to execute after the first command's implementation. When #call is
    # executed, each chained command will be called with the previous result
    # value, and its result property will be set to the previous result. The
    # return value will be wrapped in a result and returned or yielded to the
    # next block.
    #
    # @return [Cuprum::Chaining] A copy of the command, with the chained
    #   command.
    #
    # @see #yield_result
    #
    # @overload chain(command, on: nil)
    #   @param command [Cuprum::Command] The command to chain.
    #
    #   @param on [Symbol] Sets a condition on when the chained block can run,
    #     based on the previous result. Valid values are :success, :failure, and
    #     :always. If the value is :success, the block will be called only if
    #     the previous result succeeded and is not halted. If the value is
    #     :failure, the block will be called only if the previous result failed
    #     and is not halted. If the value is :always, the block will be called
    #     regardless of the previous result status, even if the previous result
    #     is halted. If no value is given, the command will run whether the
    #     previous command was a success or a failure, but not if the command
    #     chain has been halted.
    #
    # @overload chain(on: nil) { |value| }
    #   Creates an anonymous command from the given block. The command will be
    #   passed the value of the previous result.
    #
    #   @param on [Symbol] Sets a condition on when the chained block can run,
    #     based on the previous result. Valid values are :success, :failure, and
    #     :always. If the value is :success, the block will be called only if
    #     the previous result succeeded and is not halted. If the value is
    #     :failure, the block will be called only if the previous result failed
    #     and is not halted. If the value is :always, the block will be called
    #     regardless of the previous result status, even if the previous result
    #     is halted. If no value is given, the command will run whether the
    #     previous command was a success or a failure, but not if the command
    #     chain has been halted.
    #
    #   @yieldparam value [Object] The value of the previous result.
    def chain(command = nil, on: nil, &block)
      clone.chain!(command, on: on, &block)
    end

    # As #yield_result, but always returns the previous result when the block is
    # called. The return value of the block is discarded.
    #
    # @param (see #yield_result)
    #
    # @yieldparam result [Cuprum::Result] The #result of the previous command.
    #
    # @return (see #yield_result)
    #
    # @see #yield_result
    def tap_result(on: nil, &block)
      clone.tap_result!(on: on, &block)
    end

    # Creates a copy of the command, and then chains the block to execute after
    # the command implementation. When #call is executed, each chained block
    # will be yielded the previous result, and the return value wrapped in a
    # result and returned or yielded to the next block.
    #
    # @param on [Symbol] Sets a condition on when the chained block can run,
    #   based on the previous result. Valid values are :success, :failure, and
    #   :always. If the value is :success, the block will be called only if the
    #   previous result succeeded and is not halted. If the value is :failure,
    #   the block will be called only if the previous result failed and is not
    #   halted. If the value is :always, the block will be called regardless of
    #   the previous result status, even if the previous result is halted. If no
    #   value is given, the command will run whether the previous command was a
    #   success or a failure, but not if the command chain has been halted.
    #
    # @yieldparam result [Cuprum::Result] The #result of the previous command.
    #
    # @return [Cuprum::Chaining] A copy of the command, with the chained block.
    #
    # @see #tap_result
    def yield_result(on: nil, &block)
      clone.yield_result!(on: on, &block)
    end

    protected

    # @!visibility public
    #
    # As #chain, but modifies the current command instead of creating a clone.
    # This is a protected method, and is meant to be called by the command to be
    # chained, such as during #initialize.
    #
    # @return [Cuprum::Chaining] The current command.
    #
    # @see #chain
    #
    # @overload chain!(command, on: nil)
    #   @param command [Cuprum::Command] The command to chain.
    #
    #   @param on [Symbol] Sets a condition on when the chained block can run,
    #     based on the previous result. Valid values are :success, :failure, and
    #     :always. If the value is :success, the block will be called only if
    #     the previous result succeeded and is not halted. If the value is
    #     :failure, the block will be called only if the previous result failed
    #     and is not halted. If the value is :always, the block will be called
    #     regardless of the previous result status, even if the previous result
    #     is halted. If no value is given, the command will run whether the
    #     previous command was a success or a failure, but not if the command
    #     chain has been halted.
    #
    # @overload chain!(on: nil) { |value| }
    #   Creates an anonymous command from the given block. The command will be
    #   passed the value of the previous result.
    #
    #   @param on [Symbol] Sets a condition on when the chained block can run,
    #     based on the previous result. Valid values are :success, :failure, and
    #     :always. If the value is :success, the block will be called only if
    #     the previous result succeeded and is not halted. If the value is
    #     :failure, the block will be called only if the previous result failed
    #     and is not halted. If the value is :always, the block will be called
    #     regardless of the previous result status, even if the previous result
    #     is halted. If no value is given, the command will run whether the
    #     previous command was a success or a failure, but not if the command
    #     chain has been halted.
    #
    #   @yieldparam value [Object] The value of the previous result.
    def chain!(command = nil, on: nil, &block)
      command ||= Cuprum::Command.new(&block)

      chained_procs <<
        {
          proc: chain_command(command),
          on:   on
        } # end hash

      self
    end

    def chained_procs
      @chained_procs ||= []
    end

    def process_with_result(*args, &block)
      yield_chain(super)
    end

    # @!visibility public
    #
    # As #tap_result, but modifies the current command instead of creating a
    # clone. This is a protected method, and is meant to be called by the
    # command to be chained, such as during #initialize.
    #
    # @param (see #tap_result)
    #
    # @yieldparam result [Cuprum::Result] The #result of the previous command.
    #
    # @return (see #tap_result)
    #
    # @see #tap_result
    def tap_result!(on: nil, &block)
      tapped = ->(result) { result.tap { block.call(result) } }

      chained_procs <<
        {
          proc: tapped,
          on:   on
        } # end hash

      self
    end

    # @!visibility public
    #
    # As #yield_result, but modifies the current command instead of creating a
    # clone. This is a protected method, and is meant to be called by the
    # command to be chained, such as during #initialize.
    #
    # @param (see #yield_result)
    #
    # @yieldparam result [Cuprum::Result] The #result of the previous command.
    #
    # @return (see #yield_result)
    #
    # @see #yield_result
    def yield_result!(on: nil, &block)
      chained_procs <<
        {
          proc: block,
          on:   on
        } # end hash

      self
    end

    private

    def chain_command(command)
      if command.arity.zero?
        ->(result) { command.process_with_result(result) }
      else
        ->(result) { command.process_with_result(result, result.value) }
      end
    end

    def skip_chained_proc?(last_result, on:)
      return false if on == :always

      return true if last_result.respond_to?(:halted?) && last_result.halted?

      case on
      when :success
        !last_result.success?
      when :failure
        !last_result.failure?
      end
    end

    def yield_chain(first_result)
      chained_procs.reduce(first_result) do |result, hsh|
        next result if skip_chained_proc?(result, on: hsh[:on])

        value = hsh.fetch(:proc).call(result)

        if value_is_result?(value)
          value.to_result
        else
          build_result(value)
        end
      end
    end
  end
end
