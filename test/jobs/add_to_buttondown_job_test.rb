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
      user = create(:user, email: "new@example.com")

      stub_request = stub_request(:post, "https://api.buttondown.com/v1/subscribers")
        .with(body: {
          email_address: "new@example.com",
          type: "regular"
        }.to_json)
        .to_return(status: 201)

      AddToButtondownJob.perform_now(user.id)

      assert_requested(stub_request)
    end

    it "authenticates with a token and merges on collision" do
      user = create(:user, email: "repeat@example.com")

      stub_request = stub_request(:post, "https://api.buttondown.com/v1/subscribers")
        .with(headers: {
          "Authorization" => "Token buttondown-test-key",
          "X-Buttondown-Collision-Behavior" => "add",
          "X-API-Version" => Buttondown::Client::API_VERSION
        })
        .to_return(status: 201)

      AddToButtondownJob.perform_now(user.id)

      assert_requested(stub_request)
    end

    it "raises when Buttondown rejects the request" do
      user = create(:user, email: "rejected@example.com")

      stub_request(:post, "https://api.buttondown.com/v1/subscribers")
        .to_return(
          status: 400,
          body: {code: "invalid_email", detail: "Enter a valid email address."}.to_json,
          headers: {"Content-Type" => "application/json"}
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
