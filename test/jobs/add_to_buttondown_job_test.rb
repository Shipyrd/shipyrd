require "test_helper"

class AddToButtondownJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  describe "perform" do
    setup do
      ENV["BUTTONDOWN_API_KEY"] = "buttondown-test-key"
    end

    teardown do
      ENV.delete("BUTTONDOWN_API_KEY")
    end

    it "subscribes the user's email address to the newsletter" do
      user = create(:user)

      Buttondown::Client.any_instance.expects(:subscribe).once.with(user.email)

      AddToButtondownJob.perform_now(user.id)
    end

    it "lets a Buttondown failure raise rather than swallowing it" do
      user = create(:user)

      Buttondown::Client.any_instance.expects(:subscribe).raises(
        Buttondown::BadRequestError.new("Enter a valid email address.", status: 400)
      )

      assert_raises(Buttondown::BadRequestError) do
        AddToButtondownJob.perform_now(user.id)
      end
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
      assert_enqueued_with(job: AddToButtondownJob) do
        create(:user)
      end
    end

    it "does not enqueue the job in community edition" do
      ENV["COMMUNITY_EDITION"] = "1"

      assert_no_enqueued_jobs only: AddToButtondownJob do
        create(:user)
      end
    end
  end
end
