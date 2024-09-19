require "application_system_test_case"
require "helpers/basic_auth_helpers"

class DestinationsTest < ApplicationSystemTestCase
  setup do
    @api_key = ApiKey.create!
  end

  describe "with an existing destination" do
    setup do
      @application = create(:application_with_repository_url)
      @destination = create(:destination, application: @application)
    end

    test "updating" do
      visit basic_auth_url(root_url, @api_key.token)
      visit edit_application_destination_path(@application, @destination)

      assert_text "Editing #{@application.name}"

      fill_in "Branch", with: "main"
      fill_in "URL", with: "https://production.com"

      click_on "Update"

      assert_text "Destination was successfully updated"
    end

    test "recipe status" do
      visit basic_auth_url(root_url, @api_key.token)
      visit application_destination_path(@application, @destination)

      click_on "Connect to GitHub"

      Connection.any_instance.stubs(:connects_successfully)
      Connection.any_instance.stubs(:fetch_repository_content).returns("recipe")

      fill_in "connection_key", with: "key-from-github"
      click_on "Connect to GitHub"

      assert_text "Connection was successfully created."

      assert_text "Kamal recipe: queued for import"

      @destination.update!(
        recipe_last_processed_at: Time.current,
        recipe_updated_at: Time.current
      )

      visit application_destination_path(@application, @destination)

      assert_text "Kamal recipe: imported just now (processed just now)"
    end

    test "with servers" do
      @connected_server = @destination.servers.create!(host: "123.456.789.0", last_connected_at: 3.minutes.ago)
      @new_server = @destination.servers.create!(host: "123.456.789.1")

      visit basic_auth_url(root_url, @api_key.token)
      visit application_destination_path(@application, @destination)

      within "#server_#{@connected_server.id}" do
        assert_text "123.456.789.0"
        assert_text "Last connected 3 minutes ago"
      end

      assert_text "Connecting Shipyrd to your servers"
      assert_text "An SSH key pair is generated"

      within "#server_#{@new_server.id}" do
        assert_text "123.456.789.1"
      end

      @new_server.update!(last_connected_at: 2.minutes.ago)
      visit application_destination_path(@application, @destination)

      within "#server_#{@new_server.id}" do
        assert_text "Last connected 2 minutes ago"
      end
    end
  end
end
