require "test_helper"
require "helpers/basic_auth_helpers"

class MeControllerTest < ActionDispatch::IntegrationTest
  # The hosted app. Community Edition is covered separately below, where the
  # subscription gate does not apply.
  setup do
    ENV["COMMUNITY_EDITION"] = "0"

    @user = create(:user)
    @organization = create(:organization, :subscribed, name: "Acme")
    @organization.memberships.create(user: @user, role: :admin)
  end

  teardown do
    ENV.delete("COMMUNITY_EDITION")
  end

  test "returns the user and their organizations" do
    get me_url, headers: auth_headers(@user.token)

    assert_response :ok

    body = response.parsed_body
    assert_equal @user.id, body.dig("user", "id")
    assert_equal @user.email, body.dig("user", "email")
    assert_equal ["Acme"], body["organizations"].pluck("name")
    assert body["organizations"].first["active_subscription"]
    assert body["organizations"].first["admin"]
  end

  test "requires a token" do
    get me_url

    assert_response :unauthorized
    assert_equal "Authorization token required", response.parsed_body["error"]
  end

  test "rejects an invalid token" do
    get me_url, headers: auth_headers("nope")

    assert_response :unauthorized
    assert_equal "Invalid token", response.parsed_body["error"]
  end

  test "rejects an application token" do
    application = create(:application, organization: @organization)

    get me_url, headers: auth_headers(application.token)

    assert_response :unauthorized
  end

  test "requires an active subscription" do
    user = create(:user)
    create(:organization).memberships.create(user: user)

    get me_url, headers: auth_headers(user.token)

    assert_response :payment_required

    body = response.parsed_body
    assert_equal "An active Shipyrd subscription is required.", body["error"]
    assert_match "/billing/checkout", body["billing_url"]
  end

  # A trial is not a subscription for MCP purposes, and the bare organization
  # factory is on trial by virtue of its created_at.
  test "a trial does not satisfy the subscription gate" do
    user = create(:user)
    organization = create(:organization)
    organization.memberships.create(user: user)

    assert organization.trial_active?

    get me_url, headers: auth_headers(user.token)

    assert_response :payment_required
  end

  test "passes when any one organization is subscribed" do
    @organization.memberships.find_by(user: @user).destroy
    create(:organization, name: "Unpaid").memberships.create(user: @user)
    create(:organization, :subscribed, name: "Paid").memberships.create(user: @user)

    get me_url, headers: auth_headers(@user.token)

    assert_response :ok

    subscribed = response.parsed_body["organizations"].to_h { |o| [o["name"], o["active_subscription"]] }
    assert_equal({"Paid" => true, "Unpaid" => false}, subscribed)
  end

  test "refuses a non-JSON format" do
    get me_url(format: :xml), headers: auth_headers(@user.token)

    assert_response :not_acceptable
  end

  test "does not leak the token" do
    get me_url, headers: auth_headers(@user.token)

    refute_includes response.body, @user.token
  end

  describe "community edition" do
    setup do
      ENV["COMMUNITY_EDITION"] = "1"
    end

    test "does not require a subscription" do
      user = create(:user)
      create(:organization).memberships.create(user: user)

      get me_url, headers: auth_headers(user.token)

      assert_response :ok
    end
  end
end
