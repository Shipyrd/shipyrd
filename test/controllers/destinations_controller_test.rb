require "test_helper"
require "helpers/basic_auth_helpers"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = ApiKey.create!
    @application = create(:application)
    @destination = create(:destination, application: @application)
  end

  test "should get edit" do
    get edit_application_destination_path(@application, @destination), headers: auth_headers(@api_key.token)
    assert_response :success
  end

  test "should get show" do
    get application_destination_path(@application, @destination), headers: auth_headers(@api_key.token)
    assert_response :success
  end

  test "should update destination" do
    patch application_destination_path(@application, @destination), params: {destination: {branch: @destination.branch, name: @destination.name, url: @destination.url}}, headers: auth_headers(@api_key.token)
    assert_redirected_to application_destination_path(@application, @destination)
  end
end
