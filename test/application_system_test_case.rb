require "test_helper"
require "capybara/minitest"
require "helpers/system_auth"

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.disable_animation = true
Capybara.default_max_wait_time = 5
Capybara.server = :puma, {Silent: true}

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
