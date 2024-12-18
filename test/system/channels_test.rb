require "application_system_test_case"

class ChannelsTest < ApplicationSystemTestCase
  describe "with an application" do
    setup do
      @application = create(:application_with_repository_url)
      @organization = @application.organization
      @user = create(:user)
      @organization.memberships.create(user: @user)

      sign_in_as(@user.email, @user.password)
    end

    test "managing a webhook" do
      visit edit_application_path(@application)

      click_on "Connect Webhook"

      assert_text "Adding a webhook"

      fill_in "URL", with: "https://webhook.com"

      click_on "Create Webhook"

      assert_text "Webhook notifications are enabled for Deploys, Locks"
    end

    test "changing webhook settings" do
      webhook = create(:webhook, application: @application, user: @user)
      webhook.channel.update(events: ["deploy", "lock"])

      visit edit_application_path(@application)

      click_on "Edit"

      uncheck "Locks"

      click_on "Update"

      assert_text "Webhook notifications are enabled for Deploys"
    end
  end
end
