ENV["RAILS_ENV"] ||= "test"
ENV["SHIPYRD_HOST"] = "shipyrd.test"
ENV["SHIPYRD_HOOKS_HOST"] = "hooks.shipyrd.test"

require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "factory_bot_rails"
include FactoryBot::Syntax::Methods # standard:disable Style/MixinUsage

require "mocha/minitest"

Minitest.load_plugins

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end
