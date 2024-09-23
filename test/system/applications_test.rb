require "application_system_test_case"
require "helpers/basic_auth_helpers"

class ApplicationsTest < ApplicationSystemTestCase
  setup do
    @api_key = ApiKey.create!
  end

  describe "initial setup" do
    it "points to setup instructions" do
      visit basic_auth_url(root_url, @api_key.token)
      visit root_url

      assert_text "Waiting for a deploy to start..."
      assert_link "Setup instructions", href: "https://github.com/shipyrd/shipyrd"

      create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-deploy",
        version: "123456",
        performer: "Nick",
        commit_message: "Deploying the potato"
      )

      assert_text "potato"
      assert_text "pre-deploy"
      assert_text "by Nick"
      assert_text "Deploying the potato"
    end
  end

  describe "with an application available" do
    test "visiting the index" do
      deploy = create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-build",
        version: "123456"
      )

      visit basic_auth_url(root_url, @api_key.token)
      visit root_url

      assert_selector "h2", text: "potato"
      assert_content "pre-build"
      assert_content "just now"
      assert_content "by #{deploy.performer}"

      create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-deploy",
        version: "123456",
        performer: "Nick",
        commit_message: "Deploying the potato"
      )

      assert_content "pre-deploy"
      assert_content "by Nick"
      assert_content "Deploying the potato"

      deploy = create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        destination: "production",
        hosts: "867.53.0.9",
        status: "post-deploy"
      )

      # TODO: Test is failing to trigger a cable refresh
      visit root_url

      destination = deploy.application.destinations.find_by!(name: "production")

      # TODO: Add back in a link to the production URL
      assert_link "production", href: application_destination_path(destination.application.id, destination.id)
      assert_link "On Deck"

      deploy = create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-deploy",
        version: "123456",
        performer: "Nick",
        commit_message: "Deploying the potato #10"
      )
      deploy.application.update!(repository_url: "https://github.com/shipyrd/shipyrd")

      assert_link "#10", href: "https://github.com/shipyrd/shipyrd/issues/10"
    end

    test "should update Application" do
      @application = create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        destination: "production",
        status: "pre-connect",
        hosts: "867.53.0.9"
      ).application

      visit basic_auth_url(root_url, @api_key.token)
      visit root_url
      sleep(1) # TODO: Turbo page navigation isn't refreshing properly with Capybara state

      click_link "Edit this application"

      assert_text "1 server"

      fill_in "Name", with: "Potato"
      fill_in "Repository URL", with: "https://github.com/shipyrd/shipyrd"

      click_on "Update"

      assert_text "Application was successfully updated"
    end

    test "connecting GitHub" do
      @application = create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        destination: "production",
        status: "pre-connect",
        hosts: "867.53.0.9"
      ).application

      visit basic_auth_url(root_url, @api_key.token)
      visit edit_application_url(@application)

      fill_in "Repository URL", with: "https://github.com/kevin/bacon"
      click_on "Update"

      click_link "Edit this application"
      click_link "Connect to GitHub"

      Connection.any_instance.stubs(:connects_successfully)
      Connection.any_instance.stubs(:import_deploy_recipes)

      fill_in "connection_key", with: "key-from-github"
      click_on "Connect to GitHub"

      assert_text "Connection was successfully created."

      accept_confirm do
        click_on "Disconnect GitHub"
      end

      assert_text "Connection was successfully destroyed."
    end

    test "should destroy Application" do
      @application = create(
        :deploy,
        service_version: "potato@123456"
      ).application

      visit basic_auth_url(root_url, @api_key.token)
      visit edit_application_url(@application)

      accept_confirm do
        click_on "Destroy application"
      end

      assert_text "Application was successfully destroyed"
    end
  end
end
