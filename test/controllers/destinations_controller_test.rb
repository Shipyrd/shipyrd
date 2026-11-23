require "test_helper"
require "helpers/basic_auth_helpers"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @destination = create(:destination, name: "production")
    @application = @destination.application
    @organization = @application.organization
  end

  describe "anonymous" do
    it "denies access" do
      get application_destination_path(@application, @destination)

      assert_redirected_to new_session_path
    end
  end

  describe "authenticated" do
    setup do
      @user = create(:user)
      @organization.memberships.create(user: @user)
      sign_in(@user.email, @user.password)
    end

    test "get edit" do
      get edit_application_destination_path(@application, @destination)

      assert_response :success
    end

    test "get show" do
      get application_destination_path(@application, @destination)

      assert_response :success
    end

    test "update destination" do
      patch application_destination_path(@application, @destination), params: {destination: {branch: @destination.branch, name: @destination.name, url: @destination.url}}

      assert_redirected_to application_destination_path(@application, @destination)
    end

    test "lock" do
      patch lock_application_destination_path(@application, @destination)

      assert @destination.reload.locked?
      assert_redirected_to root_path
    end

    test "unlock" do
      @destination.lock!(@user)

      delete unlock_application_destination_path(@application, @destination)

      assert_not @destination.reload.locked?
      assert_redirected_to root_path
    end

    test "get deploys" do
      get deploys_application_destination_path(@application, @destination)

      assert_response :success
    end

    test "get deploys with deploy records" do
      create(:deploy, application: @application, destination: @destination.name, status: "pre-deploy", performer: @user.username, version: "abc1234")
      create(:deploy, application: @application, destination: @destination.name, status: "post-deploy", performer: @user.username, version: "abc1234", runtime: 45)

      get deploys_application_destination_path(@application, @destination)

      assert_response :success
    end
  end

  describe "API functionality" do
    setup do
      @user = create(:user)
      @organization.memberships.create(user: @user)
    end

    test "should get show with destination name via API" do
      @destination.lock!(@user)
      create(:deploy, application: @application, destination: @destination.name, status: "post-deploy", performer: @user.username, version: "123456", role: "web", runtime: 120, commit_message: "Test commit")

      get application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
      response_data = JSON.parse(response.body)
      assert_equal @application.name, response_data["application_name"]
      assert_equal @destination.name, response_data["name"]
      assert_not_nil response_data["locked_at"]
      assert_equal @user.display_name, response_data["locked_by"]
      assert_includes response_data.keys, "on_deck_url"

      latest_deploy = response_data["latest_deploy"]
      assert_equal @destination.latest_deploy.status, latest_deploy["status"]
      assert_equal @destination.latest_deploy.performer, latest_deploy["performer"]
      assert_equal @destination.latest_deploy.version, latest_deploy["version"]
      assert_equal @destination.latest_deploy.role, latest_deploy["role"]
      assert_equal @destination.latest_deploy.runtime, latest_deploy["runtime"]
      assert_equal @destination.latest_deploy.commit_message, latest_deploy["commit_message"]
      assert_includes latest_deploy.keys, "compare_url"
    end

    test "should lock destination with destination name via API" do
      patch lock_application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
      response_data = JSON.parse(response.body)
      assert_equal @destination.name, response_data["name"]
      assert_not_nil response_data["locked_at"]
      assert_equal @user.display_name, response_data["locked_by"]

      @destination.reload
      assert @destination.locked?
      assert_equal @user, @destination.locker
    end

    test "should unlock destination with destination name via API" do
      @destination.lock!(@user)

      delete unlock_application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
      response_data = JSON.parse(response.body)
      assert_equal @destination.name, response_data["name"]
      assert_nil response_data["locked_at"]
      assert_nil response_data["locked_by"]

      @destination.reload
      assert_not @destination.locked?
    end

    test "should return 404 for non-existent destination name" do
      patch lock_application_destination_path(@application, "nonexistent"),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :not_found
      response_data = JSON.parse(response.body)
      assert_equal "Not found", response_data["error"]
    end
  end
  describe "deploy history via API" do
    setup do
      @user = create(:user)
      @organization.memberships.create(user: @user)
    end

    test "returns one entry per version, newest first" do
      create(:deploy, application: @application, destination: @destination.name, version: "aaa111", status: "pre-deploy", recorded_at: 3.minutes.ago)
      create(:deploy, application: @application, destination: @destination.name, version: "aaa111", status: "post-deploy", recorded_at: 2.minutes.ago, runtime: 42)
      create(:deploy, application: @application, destination: @destination.name, version: "bbb222", status: "post-deploy", recorded_at: 1.minute.ago, commit_message: "Latest work")

      get deploys_application_destination_path(@application, @destination.name, format: :json),
        headers: auth_headers(@user.token)

      assert_response :ok

      body = JSON.parse(response.body)
      assert_equal @application.slug, body.dig("application", "slug")
      assert_equal "production", body["destination"]
      assert_equal ["bbb222", "aaa111"], body["deploys"].pluck("version")

      assert_equal "post-deploy", body["deploys"].last["status"]
      assert_equal 42, body["deploys"].last["runtime"]
      assert_equal "Latest work", body["deploys"].first["commit_message"]
    end

    test "reports a redeployed version as a separate entry" do
      create(:deploy, application: @application, destination: @destination.name, version: "aaa111", status: "post-deploy", recorded_at: 3.minutes.ago)
      create(:deploy, application: @application, destination: @destination.name, version: "bbb222", status: "post-deploy", recorded_at: 2.minutes.ago)
      create(:deploy, application: @application, destination: @destination.name, version: "aaa111", status: "post-deploy", recorded_at: 1.minute.ago)

      get deploys_application_destination_path(@application, @destination.name, format: :json),
        headers: auth_headers(@user.token)

      assert_response :ok
      assert_equal ["aaa111", "bbb222", "aaa111"], JSON.parse(response.body)["deploys"].pluck("version")
    end

    test "honours a limit" do
      3.times { |i| create(:deploy, application: @application, destination: @destination.name, version: "v#{i}", recorded_at: i.minutes.ago) }

      get deploys_application_destination_path(@application, @destination.name, format: :json),
        params: {limit: 2},
        headers: auth_headers(@user.token)

      assert_response :ok
      assert_equal 2, JSON.parse(response.body)["deploys"].length
    end

    test "clamps a limit beyond the page size and ignores a bad one" do
      create(:deploy, application: @application, destination: @destination.name, version: "aaa111")

      [999, 0, "banana"].each do |limit|
        get deploys_application_destination_path(@application, @destination.name, format: :json),
          params: {limit: limit},
          headers: auth_headers(@user.token)

        assert_response :ok
        assert_equal 1, JSON.parse(response.body)["deploys"].length
      end
    end

    test "excludes other destinations" do
      create(:destination, application: @application, name: "staging")
      create(:deploy, application: @application, destination: "staging", version: "staging1")
      create(:deploy, application: @application, destination: @destination.name, version: "prod1")

      get deploys_application_destination_path(@application, @destination.name, format: :json),
        headers: auth_headers(@user.token)

      assert_response :ok
      assert_equal ["prod1"], JSON.parse(response.body)["deploys"].pluck("version")
    end

    test "404s for another organization's application" do
      other = create(:destination, name: "production")

      get deploys_application_destination_path(other.application, "production", format: :json),
        headers: auth_headers(@user.token)

      assert_response :not_found
    end
  end

  describe "destination state via API" do
    setup do
      @user = create(:user)
      @organization.memberships.create(user: @user)
    end

    test "reports lock and business-hours state" do
      get application_destination_path(@application, @destination.name, format: :json),
        headers: auth_headers(@user.token)

      assert_response :ok

      body = JSON.parse(response.body)
      assert_equal "production", body["display_name"]
      assert_equal "main", body["branch"]
      refute body["locked"]
      refute body["auto_lock_outside_business_hours"]
      refute body["outside_business_hours"]
    end

    test "a destination with a blank name reports as default" do
      destination = create(:destination, application: @application, name: nil)

      assert destination.default?

      get application_destination_path(@application, "default", format: :json),
        headers: auth_headers(@user.token)

      assert_response :ok
      assert_equal "default", JSON.parse(response.body)["display_name"]
    end
  end
end
