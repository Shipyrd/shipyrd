ENV["RAILS_ENV"] ||= "test"
ENV["SOLID_QUEUE_IN_PUMA"] = "1"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "factory_bot_rails"
include FactoryBot::Syntax::Methods # standard:disable Style/MixinUsage
require "mocha/minitest"

WebMock.disable_net_connect!

module ActiveSupport
  class TestCase
    parallelize(workers: 1)
  end
end
