require "test_helper"

class Incoming::SlackControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secret = "test-signing-secret"
    ENV["SHIPYRD_SLACK_SIGNING_SECRET"] = @secret
    ENV["SHIPYRD_HOST"] ||= "shipyrd.test"

    @organization = create(:organization,
      slack_team_id: "T123",
      slack_team_name: "Test Workspace",
      slack_access_token: "xoxb-test")
    @user = create(:user, email: "alice@example.com")
    @membership = create(:membership, user: @user, organization: @organization)
    @application = create(:application, name: "myapp", organization: @organization)
    @destination = create(:destination, application: @application, name: "production")
  end

  teardown do
    ENV.delete("SHIPYRD_SLACK_SIGNING_SECRET")
  end

  test "raises when signing secret is not configured" do
    ENV.delete("SHIPYRD_SLACK_SIGNING_SECRET")

    assert_raises(RuntimeError) do
      post incoming_slack_url, params: slack_params(text: "status")
    end
  end

  test "returns unauthorized for missing signature headers" do
    post incoming_slack_url, params: slack_params(text: "status")

    assert_response :unauthorized
  end

  test "returns unauthorized for bad signature" do
    body = URI.encode_www_form(slack_params(text: "status"))
    headers = signed_headers(body).merge("X-Slack-Signature" => "v0=deadbeef")

    post incoming_slack_url, params: body, headers: headers

    assert_response :unauthorized
  end

  test "returns unauthorized for malformed signature (length mismatch)" do
    body = URI.encode_www_form(slack_params(text: "status"))
    headers = signed_headers(body).merge("X-Slack-Signature" => "v0=")

    post incoming_slack_url, params: body, headers: headers

    assert_response :unauthorized
  end

  test "returns unauthorized for replayed (stale) timestamp" do
    stale = (Time.now.to_i - 600).to_s
    body = URI.encode_www_form(slack_params(text: "status"))
    sig = sign(stale, body)
    headers = {
      "X-Slack-Request-Timestamp" => stale,
      "X-Slack-Signature" => sig,
      "Content-Type" => "application/x-www-form-urlencoded"
    }

    post incoming_slack_url, params: body, headers: headers

    assert_response :unauthorized
  end

  test "responds with shipyrd link when team id is unknown" do
    post_signed(team_id: "T999", text: "status")

    assert_response :success
    assert_match "isn't connected to Shipyrd", response.parsed_body["text"]
    assert_match "shipyrd.test", response.parsed_body["text"]
  end

  test "lock locks the destination when user is known" do
    @membership.update!(slack_user_id: "U123")

    post_signed(text: "lock myapp production")

    assert_response :success
    assert @destination.reload.locked?
    assert_equal @user, @destination.locker
    assert_equal "in_channel", response.parsed_body["response_type"]
  end

  test "lock reports already-locked state without mutating" do
    @membership.update!(slack_user_id: "U123")
    @destination.lock!(@user)
    locked_at = @destination.locked_at

    post_signed(text: "lock myapp production")

    assert_response :success
    assert_match "already locked", response.parsed_body["text"]
    assert_equal locked_at, @destination.reload.locked_at
  end

  test "unlock unlocks the destination" do
    @membership.update!(slack_user_id: "U123")
    @destination.lock!(@user)

    post_signed(text: "unlock myapp production")

    assert_response :success
    assert @destination.reload.unlocked?
  end

  test "rejects user whose email isn't in the organization" do
    stub_users_info(email: "stranger@example.com")

    post_signed(text: "lock myapp production")

    assert_response :success
    assert_match "doesn't match any Shipyrd user", response.parsed_body["text"]
    assert @destination.reload.unlocked?
  end

  test "binds slack_user_id on first successful email match" do
    stub_users_info(email: "alice@example.com")

    post_signed(text: "lock myapp production")

    assert_response :success
    assert_equal "U123", @membership.reload.slack_user_id
  end

  test "handles Slack API failure gracefully" do
    Faraday::Connection.any_instance.stubs(:get).raises(Faraday::TimeoutError)

    post_signed(text: "lock myapp production")

    assert_response :success
    assert_match "Unable to verify your identity", response.parsed_body["text"]
  end

  test "status with no args lists destinations" do
    @membership.update!(slack_user_id: "U123")
    @destination.lock!(@user)

    post_signed(text: "status")

    assert_response :success
    assert_equal "Deployment status", response.parsed_body["text"]
    assert response.parsed_body["blocks"].is_a?(Array)
  end

  test "lock finds app by slug" do
    @membership.update!(slack_user_id: "U123")
    multi_word_app = create(:application, name: "Pizza Tracker", organization: @organization)
    destination = create(:destination, application: multi_word_app, name: "production")

    post_signed(text: "lock #{multi_word_app.slug} production")

    assert_response :success
    assert destination.reload.locked?
  end

  test "usage is returned for unknown command" do
    post_signed(text: "frobnicate")

    assert_response :success
    assert_match "Usage:", response.parsed_body["text"]
  end

  private

  def slack_params(overrides = {})
    {
      team_id: "T123",
      user_id: "U123",
      text: ""
    }.merge(overrides)
  end

  def signed_headers(body, timestamp: Time.now.to_i.to_s)
    {
      "X-Slack-Request-Timestamp" => timestamp,
      "X-Slack-Signature" => sign(timestamp, body),
      "Content-Type" => "application/x-www-form-urlencoded"
    }
  end

  def sign(timestamp, body)
    "v0=" + OpenSSL::HMAC.hexdigest("SHA256", @secret, "v0:#{timestamp}:#{body}")
  end

  def post_signed(params)
    body = URI.encode_www_form(slack_params(params))
    post incoming_slack_url, params: body, headers: signed_headers(body)
  end

  def stub_users_info(email:)
    body = {"ok" => true, "user" => {"profile" => {"email" => email}}}
    response = stub(success?: true, body: body)
    Faraday::Connection.any_instance.stubs(:get).returns(response)
  end
end
