ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "factory_bot_rails"
include FactoryBot::Syntax::Methods
require "mocha/minitest"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end
