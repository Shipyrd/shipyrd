require "test_helper"
require "capybara/minitest"
require "helpers/system_auth"

WebMock.allow_net_connect!

Capybara.disable_animation = true
Capybara.default_max_wait_time = 10
Capybara.server = :puma, {Silent: true}

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
