require "test_helper"

class UserEmailVerificationTest < ActiveSupport::TestCase
  test "email_verified? returns true when email_verified_at is set" do
    user = build(:user, email_verified_at: Time.current)
    assert user.email_verified?
  end

  test "email_verified? returns false when email_verified_at is nil" do
    user = build(:user, :unverified)
    refute user.email_verified?
  end

  test "verification_grace_period? returns true within 7 days" do
    user = build(:user, :grace_period)
    assert user.verification_grace_period?
  end

  test "verification_grace_period? returns false after 7 days" do
    user = build(:user, :verification_required)
    refute user.verification_grace_period?
  end

  test "verification_grace_period? returns false when verified" do
    user = build(:user, email_verified_at: Time.current, created_at: 1.day.ago)
    refute user.verification_grace_period?
  end

  test "verification_required? returns true after 7 days without verification" do
    user = build(:user, :verification_required)
    assert user.verification_required?
  end

  test "verification_required? returns false during grace period" do
    user = build(:user, :grace_period)
    refute user.verification_required?
  end

  test "verification_required? returns false when verified" do
    user = build(:user, email_verified_at: Time.current)
    refute user.verification_required?
  end

  test "generates_token_for email_verification" do
    user = create(:user, :unverified)
    token = user.generate_token_for(:email_verification)

    assert_not_nil token
    assert_equal user, User.find_by_token_for(:email_verification, token)
  end

  test "email verification token expires" do
    user = create(:user, :unverified)
    token = user.generate_token_for(:email_verification)

    travel 25.hours do
      assert_nil User.find_by_token_for(:email_verification, token)
    end
  end
end
