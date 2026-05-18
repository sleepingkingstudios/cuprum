# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/initializer'

# Toolkit for implementing business logic as function objects.
module Cuprum
  autoload :Command,             'cuprum/command'
  autoload :CommandFactory,      'cuprum/command_factory'
  autoload :Currying,            'cuprum/currying'
  autoload :Error,               'cuprum/error'
  autoload :Errors,              'cuprum/errors'
  autoload :ExceptionHandling,   'cuprum/exception_handling'
  autoload :MapCommand,          'cuprum/map_command'
  autoload :Matcher,             'cuprum/matcher'
  autoload :Middleware,          'cuprum/middleware'
  autoload :Operation,           'cuprum/operation'
  autoload :ParameterValidation, 'cuprum/parameter_validation'
  autoload :Result,              'cuprum/result'
  autoload :ResultList,          'cuprum/result_list'
  autoload :Steps,               'cuprum/steps'

  @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
    SleepingKingStudios::Tools.initializer.call

    SleepingKingStudios::Tools::Messages::Registry
      .global
      .register(
        file:  File.join(Cuprum.gem_path, 'config', 'messages.yml'),
        scope: 'cuprum.errors'
      )
  end

  class << self
    # @return [SleepingKingStudios::Tools::Toolbox::Initializer] the initializer
    #   for the module.
    attr_reader :initializer

    # @return [String] the absolute path to the gem directory.
    def gem_path
      sep     = File::SEPARATOR
      pattern = /#{sep}lib#{sep}?\z/

      __dir__.sub(pattern, '')
    end

    # @return [String] the current version of the gem.
    def version
      VERSION
    end
  end
end

require 'cuprum/version'
