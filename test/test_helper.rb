ENV["RAILS_ENV"] ||= "test"
ENV["SHIPYRD_HOST"] = "shipyrd.test"
ENV["SHIPYRD_HOOKS_HOST"] = "hooks.shipyrd.test"
ENV["SHIPYRD_BADGE_HOST"] = "badge.test"

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

    def count_queries(&block)
      counted = 0

      counter = lambda do |_name, _started, _finished, _id, payload|
        next if payload[:name] == "SCHEMA"
        next if payload[:sql].match?(/\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/i)

        counted += 1
      end

      ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)

      counted
    end

    def assert_no_queries(message = "expected no further queries", &block)
      assert_equal 0, count_queries(&block), message
    end
  end
end
