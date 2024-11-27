require "application_system_test_case"

class ApplicationsTest < ApplicationSystemTestCase
  setup do
    @organization = create(:organization)
    @user = create(:user)
    @organization.memberships.create!(user: @user)

    sign_in_as(@user.email, @user.password)
  end

  describe "initial setup" do
    it "points to setup instructions" do
      visit root_url

      assert_text "Configure your first application"
      click_link "Create your first application"

      fill_in "Name", with: "potato"
      fill_in "Repository URL", with: "https://github.com/user/repo"
      click_on "Create Application"

      create(
        :deploy,
        application: create(:application, organization: @organization),
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
    setup do
      @application = create(:application, organization: @organization)
    end

    test "visiting the index" do
      deploy = create(
        :deploy,
        application: @application,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-build",
        version: "123456"
      )

      visit root_url

      assert_selector "h2", text: @application.name
      assert_content "pre-build"
      assert_content "just now"
      assert_content "by #{deploy.performer}"

      create(
        :deploy,
        application: @application,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-deploy",
        version: "123456",
        performer: "Nick",
        commit_message: "Deploying the potato"
      )

      assert_content "by Nick"
      assert_content "Deploying the potato"
      refute_link "On Deck"

      deploy = create(
        :deploy,
        application: @application,
        service_version: "potato@123456",
        version: "123456",
        command: :deploy,
        destination: "production",
        hosts: "867.53.0.9",
        status: "post-deploy"
      )

      deploy.application.update!(repository_url: "https://github.com/shipyrd/shipyrd")
      visit root_url

      destination = deploy.application.destinations.find_by!(name: "production")

      # TODO: Add back in a link to the production URL
      assert_link "production", href: application_destination_path(destination.application.id, destination.id)
      assert_link "On Deck"

      create(
        :deploy,
        application: @application,
        service_version: "potato@123456",
        command: :deploy,
        status: "pre-deploy",
        version: "123456",
        performer: "Nick",
        commit_message: "Deploying the potato #10"
      )

      assert_link "#10", href: "https://github.com/shipyrd/shipyrd/issues/10"
    end

    test "should update Application" do
      visit root_url

      click_link "Edit this application"

      fill_in "Name", with: "Potato"
      fill_in "Repository URL", with: "https://github.com/shipyrd/shipyrd"

      click_on "Update"

      assert_text "Application was successfully updated"
    end

    test "connecting GitHub" do
      visit edit_application_url(@application)

      fill_in "Repository URL", with: "https://github.com/kevin/bacon"
      click_on "Update"

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
      visit edit_application_url(@application)

      accept_confirm do
        click_on "Destroy application"
      end

      assert_text "Application was successfully destroyed"
    end
  end
end
