require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "email_verification" do
    user = create(:user, :unverified)
    email = UserMailer.email_verification(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["nick@shipyrd.io"], email.from
    assert_equal [user.email], email.to
    assert_equal "Shipyrd: Verify your email address", email.subject
    assert_match "Verify email address", email.body.encoded
  end
end
