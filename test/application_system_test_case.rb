require "test_helper"
require "capybara/minitest"
require "helpers/system_auth"
require "capybara/cuprite"

WebMock.allow_net_connect!

Capybara.disable_animation = true
Capybara.default_max_wait_time = 10
Capybara.server = :puma, {Silent: true}

Capybara.register_driver(:better_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    browser_options: {
      "no-sandbox": nil
    },
    process_timeout: 10,
    inspector: true,
    headless: !ENV["HEADLESS"].in?(%w[n 0 no false])
  )
end

Capybara.default_driver = Capybara.javascript_driver = :better_cuprite

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :better_cuprite
end
