# frozen_string_literal: true

# A lightweight, functional-lite toolkit for making business logic a first-class
# citizen of your application.
module Cuprum
  autoload :Command,    'cuprum/command'
  autoload :Error,      'cuprum/error'
  autoload :MapCommand, 'cuprum/map_command'
  autoload :Matcher,    'cuprum/matcher'
  autoload :Middleware, 'cuprum/middleware'
  autoload :Operation,  'cuprum/operation'
  autoload :Result,     'cuprum/result'
  autoload :ResultList, 'cuprum/result_list'
  autoload :Steps,      'cuprum/steps'

  class << self
    # @return [String] The current version of the gem.
    def version
      VERSION
    end
  end
end
