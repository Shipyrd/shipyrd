require "test_helper"

class Incoming::StripeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization, stripe_customer_id: "cus_test123")
    ENV["SHIPYRD_STRIPE_WEBHOOK_SECRET"] = "whsec_test"
  end

  test "returns bad request for invalid JSON" do
    Stripe::Webhook.expects(:construct_event).raises(JSON::ParserError)

    post incoming_stripe_url,
      params: "invalid json",
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :bad_request
  end

  test "returns unauthorized for invalid signature" do
    Stripe::Webhook.expects(:construct_event).raises(Stripe::SignatureVerificationError.new("Invalid", "sig"))

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "invalid"}

    assert_response :unauthorized
  end

  test "handles checkout.session.completed with subscription" do
    session = stub(
      customer: "cus_test123",
      subscription: "sub_test123"
    )
    subscription = stub(id: "sub_test123", status: "active")
    event = stub(
      type: "checkout.session.completed",
      data: stub(object: session)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)
    Stripe::Subscription.expects(:retrieve).with("sub_test123").returns(subscription)

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :ok
    @organization.reload
    assert_equal "sub_test123", @organization.stripe_subscription_id
    assert_equal "active", @organization.stripe_subscription_status
  end

  test "handles checkout.session.completed without subscription" do
    session = stub(
      customer: "cus_test123",
      subscription: nil
    )
    event = stub(
      type: "checkout.session.completed",
      data: stub(object: session)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)
    Stripe::Subscription.expects(:retrieve).never

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :ok
  end

  test "handles customer.subscription.created" do
    subscription = stub(
      customer: "cus_test123",
      id: "sub_test123",
      status: "active"
    )
    event = stub(
      type: "customer.subscription.created",
      data: stub(object: subscription)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :ok
    @organization.reload
    assert_equal "sub_test123", @organization.stripe_subscription_id
    assert_equal "active", @organization.stripe_subscription_status
  end

  test "handles customer.subscription.updated" do
    subscription = stub(
      customer: "cus_test123",
      id: "sub_test123",
      status: "past_due"
    )
    event = stub(
      type: "customer.subscription.updated",
      data: stub(object: subscription)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :ok
    @organization.reload
    assert_equal "sub_test123", @organization.stripe_subscription_id
    assert_equal "past_due", @organization.stripe_subscription_status
  end

  test "handles customer.subscription.deleted" do
    subscription = stub(
      customer: "cus_test123",
      id: "sub_test123",
      status: "canceled"
    )
    event = stub(
      type: "customer.subscription.deleted",
      data: stub(object: subscription)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :ok
    @organization.reload
    assert_equal "sub_test123", @organization.stripe_subscription_id
    assert_equal "canceled", @organization.stripe_subscription_status
  end

  test "handles invoice.payment_succeeded" do
    @organization.update!(stripe_subscription_id: "sub_test123")
    invoice = stub(
      customer: "cus_test123",
      created: @organization.created_at.to_i
    )
    event = stub(
      type: "invoice.payment_succeeded",
      data: stub(object: invoice)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :ok
    @organization.reload
    assert_equal @organization.created_at.to_i, @organization.last_payment_at.to_i
  end

  test "returns ok when organization not found" do
    session = stub(
      customer: "cus_nonexistent",
      subscription: nil
    )
    event = stub(
      type: "checkout.session.completed",
      data: stub(object: session)
    )

    Stripe::Webhook.expects(:construct_event).returns(event)

    post incoming_stripe_url,
      params: {}.to_json,
      headers: {"HTTP_STRIPE_SIGNATURE" => "test"}

    assert_response :not_found
  end
end
