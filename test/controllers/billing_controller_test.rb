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

  test "setup should redirect if payment is not required" do
    @organization.stubs(:payment_required?).returns(false)

    get billing_setup_url
    assert_redirected_to root_url
  end

  test "redirects user to Stripe billing portal" do
    @organization.update!(stripe_customer_id: "cus_test123")
    checkout_session = stub(url: "https://checkout.stripe.com/test")

    Stripe::Checkout::Session.expects(:create).with(
      customer: "cus_test123",
      mode: "subscription",
      success_url: root_url,
      cancel_url: root_url,
      allow_promotion_codes: true,
      line_items: [{
        price: "price_test123",
        quantity: 1
      }]
    ).returns(checkout_session)

    get billing_checkout_url

    assert_redirected_to "https://checkout.stripe.com/test"
  end
end
