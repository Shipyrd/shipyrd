require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  describe "create_stripe_customer" do
    it "does nothing when organization already has a stripe customer" do
      organization = create(:organization, stripe_customer_id: "cus_existing")
      user = create(:user)

      Stripe::Customer.expects(:create).never

      perform_enqueued_jobs do
        organization.memberships.create!(user: user, role: :admin)
      end
    end

    it "creates a Stripe customer and updates organization when membership is admin" do
      organization = create(:organization, stripe_customer_id: nil)
      user = create(:user, email: "admin@example.com")

      Stripe::Customer.expects(:create).with(
        email: "admin@example.com",
        metadata: {organization_id: organization.id}
      ).returns(stub(id: "cus_new123"))

      perform_enqueued_jobs do
        organization.memberships.create!(user: user, role: :admin)
      end

      assert_equal "cus_new123", organization.reload.stripe_customer_id
    end

    it "enqueues CreateStripeCustomerJob when membership is admin" do
      organization = create(:organization, stripe_customer_id: nil)
      user = create(:user)

      assert_enqueued_with(job: CreateStripeCustomerJob) do
        organization.memberships.create!(user: user, role: :admin)
      end
    end

    it "does not enqueue job when membership is not admin" do
      organization = create(:organization)
      user = create(:user)

      assert_no_enqueued_jobs only: CreateStripeCustomerJob do
        organization.memberships.create!(user: user, role: :user)
      end
    end
  end
end
