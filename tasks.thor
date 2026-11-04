# frozen_string_literal: true

require 'cuprum/cli/integrations/thor/registry'

Cuprum::Cli.initializer.call

require 'sleeping_king_studios/docs'

SleepingKingStudios::Docs.initializer.call

registry = Cuprum::Cli::Integrations::Thor::Registry.new

# CI Commands
registry.register Cuprum::Cli::Commands::Ci.commands

# File Commands
registry.register Cuprum::Cli::Commands::File.commands

# Docs Commands
registry.register SleepingKingStudios::Docs::Jekyll.commands
registry.register SleepingKingStudios::Docs::Jekyll.install_commands
