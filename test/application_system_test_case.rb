require "test_helper"
require 'capybara/minitest'

WebMock.allow_net_connect!

Capybara.disable_animation = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
