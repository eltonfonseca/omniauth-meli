require 'rspec'

require 'omniauth'
require 'omniauth/meli'

RSpec.configure do |config|
  config.extend OmniAuth::Test::StrategyMacros, type: :strategy
end
