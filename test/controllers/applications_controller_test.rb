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

    test "includes the slug and each destination's state" do
      destination = create(:destination, application: @application, name: "production")
      destination.lock!(@user)
      create(:deploy, application: @application, destination: "production", status: "post-deploy", version: "abc1234")

      get applications_url, headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok

      first_item = JSON.parse(response.body).first
      assert_equal @application.slug, first_item["slug"]
      assert_equal @application.display_name, first_item["display_name"]

      states = first_item["destination_states"]
      assert_equal 1, states.length
      assert_equal "production", states.first["name"]
      assert states.first["locked"]
      assert_equal @user.display_name, states.first["locked_by"]
      assert_equal "abc1234", states.first.dig("latest_deploy", "version")
    end

    # (application_id, name) is not a unique index, so two rows can share a name.
    test "collapses destinations that share a name" do
      create(:destination, application: @application, name: "production")
      create(:destination, application: @application, name: "production")

      get applications_url, headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok

      first_item = JSON.parse(response.body).first
      assert_equal ["production"], first_item["destination_states"].pluck("name")
      assert_equal ["production"], first_item["destinations"]
    end

    test "reports several destinations, each with its own latest deploy" do
      create(:destination, application: @application, name: "production")
      staging = create(:destination, application: @application, name: "staging")
      staging.lock!(@user)

      create(:deploy, application: @application, destination: "production", status: "post-deploy", version: "prod111")
      create(:deploy, application: @application, destination: "staging", status: "post-deploy", version: "stag222")

      get applications_url, headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok

      states = JSON.parse(response.body).first["destination_states"]
      assert_equal ["production", "staging"], states.pluck("name")

      by_name = states.to_h { |d| [d["name"], d] }
      assert_equal "prod111", by_name.dig("production", "latest_deploy", "version")
      assert_equal "stag222", by_name.dig("staging", "latest_deploy", "version")
      refute by_name["production"]["locked"]
      assert by_name["staging"]["locked"]
      assert_equal @user.display_name, by_name["staging"]["locked_by"]
    end

    # `destination_states` renders the deploy state of every destination of every
    # application, and the index is not paginated. The state is batch-loaded, so
    # the query count must not grow with the number of destinations.
    test "does not query per destination" do
      headers = {Authorization: "Bearer #{@user.token}", Accept: "application/json"}
      add_destination("production")

      one_destination = count_queries { get applications_url, headers: headers }

      %w[staging canary demo].each { |name| add_destination(name) }

      four_destinations = count_queries { get applications_url, headers: headers }

      assert_response :ok
      assert_equal 4, JSON.parse(response.body).first["destination_states"].length
      assert_equal one_destination, four_destinations,
        "destination deploy state should be batch-loaded, not queried per destination"
    end

    def add_destination(name)
      create(:destination, application: @application, name: name, branch: "main")
      create(:deploy, application: @application, destination: name, status: "post-deploy", version: "aaa#{name}")
      create(:deploy, application: @application, destination: name, status: "post-deploy", version: "bbb#{name}")
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
      assert_match(/#{app_b.display_name}.*#{@application.display_name}/m, response.body)
    end

    test "should destroy application" do
      assert_difference("Application.count", -1) do
        delete application_url(@application)
      end

      assert_redirected_to applications_url
    end
  end
end
