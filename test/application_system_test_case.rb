require "test_helper"
require 'capybara/minitest'

WebMock.allow_net_connect!

Capybara.disable_animation = true

if !ENV["ASSET_PRECOMPILE_DONE"]
  prep_passed = system "rails test:prepare"
  ENV["ASSET_PRECOMPILE_DONE"] = "true"
  abort "\nYour assets didn't compile. Exiting WITHOUT running any tests. Review the output above to resolve any errors." if !prep_passed
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
