# frozen_string_literal: true

require 'cuprum/result_helpers'

module Cuprum
  # The Steps supports step by step processes that halt on a failed step.
  #
  # After including Cuprum::Steps, use the #steps instance method to wrap a
  # series of instructions. Each instruction is then defined using the #step
  # method. Steps can be defined either as a block or as a method invocation.
  #
  # When the steps block is evaluated, each step is called in sequence. If the
  # step resolves to a passing result, the result value is returned and
  # execution continues to the next step. If all of the steps pass, then the
  # result of the final step is returned from the #steps block.
  #
  # Conversely, if any step resolves to a failing result, that failing result is
  # immediately returned from the #steps block. No further steps will be called.
  #
  # For example, consider updating a database record using a primary key and an
  # attributes hash. Broken down into its basics, this requires the following
  # instructions:
  #
  # - Using the primary key, find the existing record in the database.
  # - Update the record object with the given attributes.
  # - Save the updated record back to the database.
  #
  # Note that each of these steps can fail for different reasons. For example,
  # if a record with the given primary key does not exist in the database, then
  # the first instruction will fail, and the follow up steps should not be
  # executed. Further, whatever context is executing these steps probably wants
  # to know which step failed, and why.
  #
  # @example Defining Methods As Steps
  #   def assign_attributes(record, attributes); end
  #
  #   def find_record(primary_key); end
  #
  #   def save_record(record); end
  #
  #   def update_record(primary_key, attributes)
  #     steps do
  #       record = step :find_record,       primary_key
  #       record = step :assign_attributes, record, attributes
  #       step :save_record, record
  #     end
  #   end
  #
  # @example Defining Blocks As Steps
  #   class AssignAttributes < Cuprum::Command; end
  #
  #   class FindRecord < Cuprum::Command; end
  #
  #   class SaveRecord < Cuprum::Command; end
  #
  #   def update_record(primary_key, attributes)
  #     steps do
  #       record = step { FindRecord.new.call(primary_key) }
  #       record = step { AssignAttributes.new.call(record, attributes) }
  #       step { SaveRecord.new.call(record) }
  #     end
  #   end
  module Steps
    include Cuprum::ResultHelpers

    class << self
      # @!visibility private
      def execute_method(receiver, method_name, *args, **kwargs, &block)
        if block_given? && kwargs.empty?
          receiver.send(method_name, *args, &block)
        elsif block_given?
          receiver.send(method_name, *args, **kwargs, &block)
        elsif kwargs.empty?
          receiver.send(method_name, *args)
        else
          receiver.send(method_name, *args, **kwargs)
        end
      end

      # @!visibility private
      def extract_result_value(result)
        return result unless result.respond_to?(:to_cuprum_result)

        result = result.to_cuprum_result

        return result.value if result.success?

        throw :cuprum_failed_step, result
      end

      # rubocop:disable Metrics/MethodLength
      # @!visibility private
      def validate_method_name(method_name)
        if method_name.nil?
          raise ArgumentError,
            'expected a block or a method name',
            caller(1..-1)
        end

        unless method_name.is_a?(String) || method_name.is_a?(Symbol)
          raise ArgumentError,
            'expected method name to be a String or Symbol',
            caller(1..-1)
        end

        return unless method_name.empty?

        raise ArgumentError, "method name can't be blank", caller(1..-1)
      end
      # rubocop:enable Metrics/MethodLength
    end

    # @overload step()
    #   Executes the block and returns the value, or halts on a failure.
    #
    #   @yield Called with no parameters.
    #
    #   @return [Object] the #value of the result, or the returned object.
    #
    #   The #step method is used to evaluate a sequence of processes, and to
    #   fail fast and halt processing if any of the steps returns a failing
    #   result. Each invocation of #step should be wrapped in a #steps block,
    #   or used inside the #process method of a Command.
    #
    #   If the object returned by the block is a Cuprum result or compatible
    #   object (such as a called operation), the value is converted to a Cuprum
    #   result via the #to_cuprum_result method. Otherwise, the object is
    #   returned directly from #step.
    #
    #   If the returned object is a passing result, the #value of the result is
    #   returned by #step.
    #
    #   If the returned object is a failing result, then #step will throw
    #   :cuprum_failed_result and the failing result. This is caught by the
    #   #steps block, and halts execution of any subsequent steps.
    #
    #   @example Calling a Step
    #     # The #do_something method returns the string 'some value'.
    #     step { do_something() } #=> 'some value'
    #
    #     value = step { do_something() }
    #     value #=> 'some value'
    #
    #   @example Calling a Step with a Passing Result
    #     # The #do_something_else method returns a Cuprum result with a value
    #     # of 'another value'.
    #     step { do_something_else() } #=> 'another value'
    #
    #     # The result is passing, so the value is extracted and returned.
    #     value = step { do_something_else() }
    #     value #=> 'another value'
    #
    #   @example Calling a Step with a Failing Result
    #     # The #do_something_wrong method returns a failing Cuprum result.
    #     step { do_something_wrong() } # Throws the :cuprum_failed_step symbol.
    #
    # @overload step(method_name, *arguments, **keywords)
    #   Calls the method and returns the value, or halts on a failure.
    #
    #   @param method_name [String, Symbol] The name of the method to call. Must
    #     be the name of a method on the current object.
    #   @param arguments [Array] Positional arguments to pass to the method.
    #   @param keywords [Hash] Keyword arguments to pass to the method.
    #
    #   @yield A block to pass to the method.
    #
    #   @return [Object] the #value of the result, or the returned object.
    #
    #   The #step method is used to evaluate a sequence of processes, and to
    #   fail fast and halt processing if any of the steps returns a failing
    #   result. Each invocation of #step should be wrapped in a #steps block,
    #   or used inside the #process method of a Command.
    #
    #   If the object returned by the block is a Cuprum result or compatible
    #   object (such as a called operation), the value is converted to a Cuprum
    #   result via the #to_cuprum_result method. Otherwise, the object is
    #   returned directly from #step.
    #
    #   If the returned object is a passing result, the #value of the result is
    #   returned by #step.
    #
    #   If the returned object is a failing result, then #step will throw
    #   :cuprum_failed_result and the failing result. This is caught by the
    #   #steps block, and halts execution of any subsequent steps.
    #
    #   @example Calling a Step
    #     # The #zero method returns the integer 0.
    #     step :zero #=> 0
    #
    #     value = step :zero
    #     value #=> 0
    #
    #   @example Calling a Step with a Passing Result
    #     # The #add method adds the numbers and returns a Cuprum result with a
    #     # value equal to the sum.
    #     step :add, 2, 2
    #     #=> 4
    #
    #     # The result is passing, so the value is extracted and returned.
    #     value = step :add, 2, 2
    #     value #=> 4
    #
    #   @example Calling a Step with a Failing Result
    #     # The #divide method returns a failing Cuprum result when the second
    #     # argument is zero.
    #     step :divide, 1, 0
    #     # Throws the :cuprum_failed_step symbol, which should be caught by the
    #     # enclosing #steps block.
    def step(method_name = nil, *args, **kwargs, &block)
      result =
        if !block_given? || method_name || !args.empty? || !kwargs.empty?
          Cuprum::Steps.validate_method_name(method_name)

          Cuprum::Steps
            .execute_method(self, method_name, *args, **kwargs, &block)
        else
          block.call
        end

      Cuprum::Steps.extract_result_value(result)
    end

    # Returns the first failing #step result, or the final result if none fail.
    #
    # The #steps method is used to wrap a series of #step calls. Each step is
    # executed in sequence. If any of the steps returns a failing result, that
    # result is immediately returned from #steps. Otherwise, #steps wraps the
    # value returned by a block in a Cuprum result.
    #
    # @yield Called with no parameters.
    #
    # @yieldreturn A Cuprum result, or an object to be wrapped in a result.
    #
    # @return [Cuprum::Result] the result or object returned by the block,
    #   wrapped in a Cuprum result.
    #
    # @example With A Passing Step
    #   result = steps do
    #     step { success('some value') }
    #   end
    #   result.class    #=> Cuprum::Result
    #   result.success? #=> true
    #   result.value    #=> 'some value'
    #
    # @example With A Failing Step
    #   result = steps do
    #     step { failure('something went wrong') }
    #   end
    #   result.class    #=> Cuprum::Result
    #   result.success? #=> false
    #   result.error    #=> 'something went wrong'
    #
    # @example With Multiple Steps
    #   result = steps do
    #     # This step is passing, so execution continues on to the next step.
    #     step { success('first step') }
    #
    #     # This step is failing, so execution halts and returns this result.
    #     step { failure('second step') }
    #
    #     # This step will never be called.
    #     step { success('third step') }
    #   end
    #   result.class    #=> Cuprum::Result
    #   result.success? #=> false
    #   result.error    #=> 'second step'
    def steps(&block)
      raise ArgumentError, 'no block given' unless block_given?

      result = catch(:cuprum_failed_step) { block.call }

      return result if result.respond_to?(:to_cuprum_result)

      success(result)
    end
  end
end
