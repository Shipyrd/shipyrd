require "test_helper"

class AddToBrevoListJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  describe "perform" do
    it "creates a Brevo contact with the user's email on the product updates list" do
      user = create(:user, email: "new@example.com")

      api_instance = mock
      Brevo::ContactsApi.expects(:new).returns(api_instance)
      api_instance.expects(:create_contact).with { |contact|
        assert_equal "new@example.com", contact.email
        assert_equal [3], contact.list_ids
        assert_equal true, contact.update_enabled
      }

      AddToBrevoListJob.perform_now(user.id)
    end
  end

  describe "enqueue on user create" do
    setup do
      ENV["COMMUNITY_EDITION"] = "0"
    end

    teardown do
      ENV.delete("COMMUNITY_EDITION")
    end

    it "enqueues the job when a user is created" do
      assert_enqueued_with(job: AddToBrevoListJob) do
        create(:user)
      end
    end

    it "does not enqueue the job in community edition" do
      ENV["COMMUNITY_EDITION"] = "1"

      assert_no_enqueued_jobs only: AddToBrevoListJob do
        create(:user)
      end
    end
  end
end
