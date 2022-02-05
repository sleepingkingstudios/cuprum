# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Namespace for custom Cuprum error classes.
  module Errors
    autoload :CommandNotImplemented, 'cuprum/errors/command_not_implemented'
    autoload :MultipleErrors,        'cuprum/errors/multiple_errors'
    autoload :OperationNotCalled,    'cuprum/errors/operation_not_called'
    autoload :UncaughtException,     'cuprum/errors/uncaught_exception'
  end
end
