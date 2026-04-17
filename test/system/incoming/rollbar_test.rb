require "application_system_test_case"

class Incoming::RollbarTest < ApplicationSystemTestCase
  setup do
    @application = create(:application)
    @organization = @application.organization
    @user = create(:user)
    @organization.memberships.create(user: @user)

    sign_in_as(@user.email, @user.password)
  end

  test "setting up a rollbar incoming webhook" do
    visit setup_application_path(@application)

    click_on "Rollbar"

    assert_text "How to setup Rollbar with Shipyrd"

    click_on "Connect Rollbar"

    assert_text "Incoming webhook was successfully created"
    assert_text "Disconnect"

    accept_confirm do
      click_on "Disconnect"
    end

    assert_text "Incoming webhook was successfully destroyed"
    assert_no_text "Disconnect"
  end
end
