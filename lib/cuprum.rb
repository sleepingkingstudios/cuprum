# A lightweight, functional-lite toolkit for making business logic a first-class
# citizen of your application.
module Cuprum
  autoload :Function,  'cuprum/function'
  autoload :Operation, 'cuprum/operation'
  autoload :Result,    'cuprum/result'

  # @return [String] The current version of the gem.
  def self.version
    VERSION
  end # class method version
end # module
