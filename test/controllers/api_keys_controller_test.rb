require "test_helper"
require "helpers/basic_auth_helpers"

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = create(:api_key)
  end

  test "should get index" do
    get api_keys_url, headers: auth_headers(@api_key.token)

    assert_response :success
  end

  test "should create api_key" do
    assert_difference("ApiKey.count") do
      post api_keys_url, params: {api_key: {token: @api_key.token}}, headers: auth_headers(@api_key.token)
    end

    assert_redirected_to api_key_url(ApiKey.last)
  end

  test "should destroy api_key" do
    assert_difference("ApiKey.count", -1) do
      delete api_key_url(@api_key), headers: auth_headers(@api_key.token)
    end

    assert_redirected_to api_keys_url
  end
end
