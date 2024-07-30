require "application_system_test_case"
require "helpers/basic_auth_helpers"

class ApplicationsTest < ApplicationSystemTestCase
  setup do
    @api_key = ApiKey.create!
  end

  it "requires authentication" do
    visit root_url

    assert_text "HTTP Basic: Access denied."
  end

  describe "with an existing destination" do
    setup do
      @application = create(:application)
      @destination = create(:destination, application: @application)
    end

    test "updating" do
      visit basic_auth_url(root_url, @api_key.token)
      visit edit_application_destination_path(@application, @destination)

      assert_text "Editing #{@application.name} #{@destination.name}"

      fill_in "Branch", with: "main"
      fill_in "URL", with: "https://production.com"

      click_on "Update"

      assert_text "Destination was successfully updated"
    end
  end
end
