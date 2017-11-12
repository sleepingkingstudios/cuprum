# A lightweight, functional-lite toolkit for making business logic a first-class
# citizen of your application.
module Cuprum
  autoload :Function,  'cuprum/function'
  autoload :Operation, 'cuprum/operation'
  autoload :Result,    'cuprum/result'

  DEFAULT_WARNING_PROC = ->(message) { Kernel.warn message }
  private_constant :DEFAULT_WARNING_PROC

  class << self
    # @return [Proc] The proc called to display a warning message. By default,
    #   delegates to Kernel#warn. Set this to configure the warning behavior
    #   (e.g. to call a Logger).
    attr_writer :warning_proc

    # @return [String] The current version of the gem.
    def version
      VERSION
    end # method version

    # Displays a warning message. By default, delegates to Kernel#warn. The
    # warning behavior can be configured (e.g. to call a Logger) using the
    # #warning_proc= method.
    #
    # @param message [String] The warning message to display.
    #
    # @see #warning_proc=
    def warn message
      warning_proc.call(message)
    end # method warn

    private

    def warning_proc
      @warning_proc ||= DEFAULT_WARNING_PROC
    end # method warning_proc
  end # eigenclass
end # module
