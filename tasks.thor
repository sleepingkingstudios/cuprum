# frozen_string_literal: true

load 'sleeping_king_studios/docs/tasks.rb'

require 'cuprum/cli/integrations/thor/registry'

Cuprum::Cli.initializer.call

registry = Cuprum::Cli::Integrations::Thor::Registry.new

registry.register Cuprum::Cli::Commands::Ci.commands
