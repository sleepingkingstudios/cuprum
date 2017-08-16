# lib/cuprum/function.rb

require 'cuprum/result'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # consistent interface and tracking of result value and status.
  class Function
    # Error class for calling a Function that was not given a definition block
    # or have a #process method defined.
    class NotImplementedError < StandardError
      # Error message for a NotImplementedError.
      DEFAULT_MESSAGE = 'no implementation defined for function'.freeze

      def initialize message = nil
        super(message || DEFAULT_MESSAGE)
      end # constructor
    end # class

    def initialize &implementation
      define_singleton_method :process, &implementation if implementation
    end # method initialize

    def call *args, &block
      Cuprum::Result.new.tap do |result|
        @errors = result.errors

        result.value = process(*args, &block)

        @errors = nil
      end # tap
    end # method call

    private

    attr_reader :errors

    def process *_args
      raise NotImplementedError, nil, caller(1..-1)
    end # method process
  end # class
end # module
