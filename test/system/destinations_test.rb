require "application_system_test_case"

class DestinationsTest < ApplicationSystemTestCase
  describe "with an existing destination" do
    setup do
      @destination = create(:destination)
      @application = @destination.application
      @organization = @application.organization

      @user = create(:user)
      @organization.memberships.create(user: @user)

      sign_in_as(@user.email, @user.password)
    end

    test "updating" do
      visit edit_application_destination_path(@application, @destination)

      assert_text "Editing #{@application.name}"

      fill_in "Branch", with: "main"
      fill_in "URL", with: "https://production.com"

      click_on "Update"

      assert_text "Destination was successfully updated"
    end

    test "with servers" do
      @connected_server = @destination.servers.create!(host: "123.456.789.0", last_connected_at: 3.minutes.ago)
      @new_server = @destination.servers.create!(host: "123.456.789.1")

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

    test "locking/unlocking a destination" do
      create(
        :deploy,
        application: @application,
        service_version: "potato@123456",
        command: :deploy,
        status: "post-deploy",
        version: "123456"
      )

      visit root_url

      click_on "Lock"

      assert_text "Locked by #{@user.display_username}"

      click_on "Unlock"

      refute_text "Locked by"
    end
  end
end
