# A lightweight, functional-lite toolkit for making business logic a first-class
# citizen of your application.
module Cuprum
  autoload :Command,   'cuprum/command'
  autoload :Operation, 'cuprum/operation'
  autoload :Result,    'cuprum/result'

  class << self
    # @return [String] The current version of the gem.
    def version
      VERSION
    end # method version
  end # eigenclass
end # module
