require "test_helper"
require "helpers/basic_auth_helpers"

class BillingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
    @user = create(:user)
    @organization.memberships.create(user: @user, role: :admin)
    sign_in @user.email, @user.password
    ENV["SHIPYRD_STRIPE_PRICE_ID"] = "price_test123"
  end

  test "should create Stripe customer and redirect to checkout when customer does not exist" do
    customer = stub(id: "cus_test123")
    checkout_session = stub(url: "https://checkout.stripe.com/test")

    Stripe::Customer.expects(:create).with(
      email: @user.email,
      metadata: {
        organization_id: @organization.id
      }
    ).returns(customer)

    Stripe::Checkout::Session.expects(:create).with(
      customer: "cus_test123",
      mode: "subscription",
      success_url: root_url,
      cancel_url: root_url,
      line_items: [{
        price: "price_test123",
        quantity: 1
      }]
    ).returns(checkout_session)

    get billing_checkout_url

    assert_redirected_to "https://checkout.stripe.com/test"
    @organization.reload
    assert_equal "cus_test123", @organization.stripe_customer_id
  end

  test "should use existing Stripe customer and redirect to checkout" do
    @organization.update!(stripe_customer_id: "cus_existing123")
    checkout_session = stub(url: "https://checkout.stripe.com/test")

    Stripe::Customer.expects(:create).never

    Stripe::Checkout::Session.expects(:create).with(
      customer: "cus_existing123",
      mode: "subscription",
      success_url: root_url,
      cancel_url: root_url,
      line_items: [{
        price: "price_test123",
        quantity: 1
      }]
    ).returns(checkout_session)

    get billing_checkout_url

    assert_redirected_to "https://checkout.stripe.com/test"
  end
end
