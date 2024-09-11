# frozen_string_literal: true

# Toolkit for implementing business logic as function objects.
module Cuprum
  autoload :Command,             'cuprum/command'
  autoload :CommandFactory,      'cuprum/command_factory'
  autoload :Currying,            'cuprum/currying'
  autoload :Error,               'cuprum/error'
  autoload :ExceptionHandling,   'cuprum/exception_handling'
  autoload :MapCommand,          'cuprum/map_command'
  autoload :Matcher,             'cuprum/matcher'
  autoload :Middleware,          'cuprum/middleware'
  autoload :Operation,           'cuprum/operation'
  autoload :ParameterValidation, 'cuprum/parameter_validation'
  autoload :Result,              'cuprum/result'
  autoload :ResultList,          'cuprum/result_list'
  autoload :Steps,               'cuprum/steps'

  class << self
    # @return [String] the current version of the gem.
    def version
      VERSION
    end
  end
end

require 'cuprum/version'
