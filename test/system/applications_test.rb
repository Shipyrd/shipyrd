require "application_system_test_case"
require "helpers/basic_auth_helpers"

class ApplicationsTest < ApplicationSystemTestCase
  setup do
    @api_key = ApiKey.create!
  end

  describe "initial setup" do
    it "requires authentication" do
      visit root_url

      assert_text "HTTP Basic: Access denied."
    end

    it "points to setup instructions" do
      visit basic_auth_url(root_url, @api_key.token)

      assert_text "Waiting for a deploy to start..."
      assert_link "Setup instructions", href: "https://github.com/shipyrd/shipyrd"
    end
  end

  describe "with an application avaiable" do
    setup do
      @deploy = create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-build",
        version: "123456"
      )
    end

    test "visiting the index" do
      visit basic_auth_url(root_url, @api_key.token)
      visit root_url

      assert_selector "h2", text: "potato"
      assert_content "pre-build"
      assert_content "less than a minute ago"
      assert_content "by #{@deploy.performer}"

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

      create(
        :deploy,
        service_version: "potato@123456",
        command: :deploy,
        destination: "production",
        status: "post-deploy"
      )

      destination = @deploy.application.destinations.find_by(name: "production")
      destination.update!(url: "https://production.com")

      assert_link "production", href: destination.url
    end

    test "should update Application" do
      @application = create(
        :deploy,
        service_version: "potato@123456",
        destination: "production"
      ).application

      visit basic_auth_url(root_url, @api_key.token)
      visit root_url

      click_on "Edit this application", match: :first

      fill_in "Name", with: @application.name
      fill_in "Repository URL", with: @application.repository_url
      within_fieldset "production" do
        fill_in "Branch", with: "main"
        fill_in "URL", with: "https://production.com"
      end
      click_on "Update"

      assert_text "Application was successfully updated"
    end

    test "should destroy Application" do
      @application = create(
        :deploy,
        service_version: "potato@123456"
      ).application

      visit basic_auth_url(root_url, @api_key.token)
      visit application_url(@application)

      click_on "Destroy"

      assert_text "Application was successfully destroyed"
    end
  end
end
