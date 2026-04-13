require "test_helper"
require "helpers/basic_auth_helpers"

class ApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization
  end

  describe "anonymous" do
    it "denies access" do
      get applications_url
      assert_redirected_to new_session_path
    end
  end

  describe "via JSON" do
    before do
      @user = create(:user)
      @organization.users << @user
    end

    test "should get applications index with valid user token for JSON requests" do
      create(:destination, application: @application, name: "production")

      get applications_url, headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
      response_data = JSON.parse(response.body)
      assert response_data.is_a?(Array)
      first_item = response_data.first
      assert_equal @application.id, first_item["id"]
      assert_equal @application.name, first_item["name"]
      assert_equal ["production"], first_item["destinations"]
    end
  end

  describe "authenticated" do
    before do
      @user = create(:user)
      @organization.users << @user
      sign_in(@user.email, @user.password)
    end

    test "should get index" do
      get applications_url

      assert_response :success
    end

    test "should get new" do
      get new_application_url
      assert_response :success
    end

    test "should create" do
      assert_difference("Application.count") do
        post applications_url, params: {application: {name: "New App", repository_url: "https://github.com/user/repo"}}
      end
    end

    test "should show application" do
      get application_url(@application)

      assert_response :success
    end

    test "should get edit" do
      get edit_application_url(@application)

      assert_response :success
    end

    test "should update application" do
      patch application_url(@application), params: {application: {name: @application.name, repository_url: @application.repository_url}}

      assert_redirected_to edit_application_url(@application)
    end

    test "should move application up" do
      @application.update!(sort_order: 5)

      patch move_up_application_url(@application)

      assert_redirected_to applications_url
      assert_equal 4, @application.reload.sort_order
    end

    test "should move application down" do
      @application.update!(sort_order: 5)

      patch move_down_application_url(@application)

      assert_redirected_to applications_url
      assert_equal 6, @application.reload.sort_order
    end

    test "should order applications by sort_order" do
      app_b = create(:application, organization: @organization, sort_order: -1)

      get applications_url

      assert_response :success
      apps = assigns(:applications)
      assert_equal app_b, apps.first
    end

    test "should destroy application" do
      assert_difference("Application.count", -1) do
        delete application_url(@application)
      end

      assert_redirected_to applications_url
    end
  end
end
