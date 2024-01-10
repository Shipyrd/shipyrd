require "application_system_test_case"
require "helpers/http_basic_auth"

class ApplicationsTest < ApplicationSystemTestCase
  describe "initial setup" do
    setup do
      @api_key = ApiKey.create
    end

    it "requires authentication" do
      visit root_url

      assert_text "HTTP Basic: Access denied."
    end

    it "points to setup instructions" do
      url = URI(root_url)
      url.userinfo = ":#{@api_key.token}"
      visit url.to_s

      assert_text "No deploy information found yet"
      click_link "Setup instructions"
    end
  end

  describe "with an application avaiable" do
    setup do
      skip
      @application = create(:application)
    end
    test "visiting the index" do
      visit applications_url
      assert_selector "h1", text: "Applications"
    end

    test "should create application" do
      visit applications_url
      click_on "New application"

      fill_in "Environment", with: @application.environment
      fill_in "Name", with: @application.name
      fill_in "Repository url", with: @application.repository_url
      fill_in "Url", with: @application.url
      click_on "Create Application"

      assert_text "Application was successfully created"
      click_on "Back"
    end

    test "should update Application" do
      visit application_url(@application)
      click_on "Edit this application", match: :first

      fill_in "Environment", with: @application.environment
      fill_in "Name", with: @application.name
      fill_in "Repository url", with: @application.repository_url
      fill_in "Url", with: @application.url
      click_on "Update Application"

      assert_text "Application was successfully updated"
      click_on "Back"
    end

    test "should destroy Application" do
      visit application_url(@application)
      click_on "Destroy this application", match: :first

      assert_text "Application was successfully destroyed"
    end
  end
end
