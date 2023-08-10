ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "factory_bot_rails"
include FactoryBot::Syntax::Methods

module ActiveSupport
  class TestCase
    # parallelize(workers: :number_of_processors)
  end
end
