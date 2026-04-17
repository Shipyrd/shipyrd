require "application_system_test_case"

class Incoming::AppsignalTest < ApplicationSystemTestCase
  setup do
    @application = create(:application)
    @organization = @application.organization
    @user = create(:user)
    @organization.memberships.create(user: @user)

    sign_in_as(@user.email, @user.password)
  end

  test "setting up an appsignal incoming webhook" do
    visit setup_application_path(@application)

    click_on "AppSignal"

    assert_text "How to setup AppSignal with Shipyrd"

    click_on "Create Incoming webhook"

    assert_text "Incoming webhook was successfully created"
    assert_text "Disconnect Appsignal"

    accept_confirm do
      click_on "Disconnect Appsignal"
    end

    assert_text "Incoming webhook was successfully destroyed"
    assert_no_text "Disconnect Appsignal"
  end
end
