require "test_helper"
require "helpers/basic_auth_helpers"

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization
    @user = create(:user)
    @organization.memberships.create(user: @user, role: :admin)
    @webhook = create(:webhook, user: @user, application: @application)
    @channel = create(:channel, channel_type: :webhook, owner: @webhook, application: @application)
  end

  describe "anonymous" do
    it "denies access" do
      get edit_application_channel_url(@application, @channel)

      assert_redirected_to new_session_path
    end
  end

  describe "authenticated" do
    setup do
      sign_in(@user.email, @user.password)
    end

    test "should get edit" do
      get edit_application_channel_url(@application, @channel)
      assert_response :success
    end

    test "should update channel" do
      patch application_channel_url(@application, @channel), params: {channel: {events: ["event1", "event2"]}}
      assert_redirected_to edit_application_path(@application)
      assert_equal "#{@channel.display_name} connection was successfully updated.", flash[:notice]
    end
  end
end
