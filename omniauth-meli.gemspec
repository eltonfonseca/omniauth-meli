# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require_relative 'lib/omniauth/meli/version'

Gem::Specification.new do |gem|
  gem.name = 'omniauth-meli'
  gem.version = OmniAuth::Meli::VERSION
  gem.authors = ['Elton Fonseca']
  gem.email = ['eltonjuniorfonseca@gmail.com']

  gem.summary = 'Omniauth strategy for Mercado Livre.'
  gem.description = 'Omniauht strategy for Mercado Livre.'
  gem.homepage = 'https://github.com/eltonfonseca/omniauth-meli'
  gem.license = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 3.2'

  gem.add_dependency 'omniauth', '~> 2.1.2'
  gem.add_dependency 'omniauth-oauth2', '~> 1.8'
  gem.add_development_dependency 'rspec', '~> 3.5'
  gem.add_development_dependency 'rubocop', '~> 1.50.1'
end
