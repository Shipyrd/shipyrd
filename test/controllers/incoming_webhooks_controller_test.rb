require "test_helper"
require "helpers/basic_auth_helpers"

class IncomingWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization
    @incoming_webhook = create(:incoming_webhook, application: @application)
    @user = create(:user)
    @organization.memberships.create(user: @user)

    sign_in(@user.email, @user.password)
  end

  test "should get new" do
    get new_application_incoming_webhook_url(@application, provider: :honeybadger)
    assert_response :success
  end

  test "should create incoming_webhook" do
    assert_difference("IncomingWebhook.count") do
      post application_incoming_webhooks_url(@application), params: {incoming_webhook: {provider: :honeybadger, token: @incoming_webhook.token}}
    end

    assert_redirected_to edit_application_url(@application)
  end

  test "should destroy incoming_webhook" do
    assert_difference("IncomingWebhook.count", -1) do
      delete application_incoming_webhook_url(@application, @incoming_webhook)
    end

    assert_redirected_to edit_application_url(@application)
  end
end
