require "test_helper"
require "helpers/basic_auth_helpers"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization

    @user = create(:user)
    @organization.memberships.create(user: @user, role: :admin)
    sign_in @user.email, @user.password
  end

  test "should get new" do
    get new_application_webhook_url(@application)
    assert_response :success
  end

  test "should create webhook" do
    assert_difference("Webhook.count") do
      post application_webhooks_url(@application), params: {webhook: {url: "http://example.com"}}
    end

    assert_redirected_to edit_application_url(@application)
  end

  test "should not create webhook with invalid params" do
    assert_no_difference("Webhook.count") do
      post application_webhooks_url(@application), params: {webhook: {url: ""}}
    end

    assert_response :unprocessable_entity
  end
end
