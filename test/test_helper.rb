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

    # Counts the queries a block runs, ignoring schema reads and transaction
    # bookkeeping. For pinning down a batch load that should not grow with the
    # number of rows it covers. Cache hits count: tests run inside a
    # transaction with the query cache on, so skipping them would hide the very
    # queries we are counting, and a cache hit is still a query the code asked
    # for rather than batched.
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
