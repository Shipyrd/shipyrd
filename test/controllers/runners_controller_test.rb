require "test_helper"
require "helpers/basic_auth_helpers"

class RunnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = ApiKey.create!
    @application = create(:application)
    @destination = create(:destination, application: @application)
  end

  describe "anonymous" do
    it "denies access" do
      get application_destination_runners_path(@application, @destination)
      assert_response :unauthorized
    end
  end

  test "should get index" do
    get application_destination_runners_path(@application, @destination), headers: auth_headers(@api_key.token)
    assert_response :success
  end

  test "should get new" do
    get new_application_destination_runner_path(@application, @destination), headers: auth_headers(@api_key.token)
    assert_response :success
  end

  test "should get show" do
    @runner = create(:runner, destination: @destination)

    get application_destination_runner_path(@application, @destination, @runner), headers: auth_headers(@api_key.token)
    assert_response :success
  end

  test "should create runner" do
    post application_destination_runners_path(@application, @destination), params: {runner: {command: "lock status"}}, headers: auth_headers(@api_key.token)

    @runner = @destination.runners.last

    assert_redirected_to application_destination_runner_path(@application, @destination, @runner)
  end
end
