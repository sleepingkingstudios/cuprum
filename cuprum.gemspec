$LOAD_PATH << './lib'

require 'cuprum/version'

Gem::Specification.new do |gem|
  gem.name        = 'cuprum'
  gem.version     = Cuprum::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary     = 'An opinionated implementation of the Command pattern.'

  description = <<-DESCRIPTION
    An opinionated implementation of the Command pattern for Ruby applications.
    Cuprum wraps your business logic in a consistent, object-oriented interface
    and features status and error management, composability and control flow
    management.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'sleeping_king_studios-tools', '~> 0.8'

  gem.add_development_dependency 'rspec',                       '~> 3.6'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.3'
  gem.add_development_dependency 'rubocop',                     '~> 0.49.1'
  gem.add_development_dependency 'rubocop-rspec',               '~> 1.15'
  gem.add_development_dependency 'simplecov',                   '~> 0.15'
end
