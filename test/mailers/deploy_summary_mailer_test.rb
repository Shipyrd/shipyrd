require "test_helper"

class DeploySummaryMailerTest < ActionMailer::TestCase
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  let(:summary_data) do
    {
      total_deploys: 5,
      previous_week_deploys: 3,
      applications: [
        ["my-app", {total: 3, runtime: 450, destinations: [["production", 2], ["staging", 1]]}],
        ["api", {total: 2, runtime: 180, destinations: [["production", 2]]}]
      ],
      deployers: [["Nick", 3], ["Rehan", 2]],
      period_start: 7.days.ago,
      period_end: Time.current
    }
  end

  test "weekly_summary" do
    email = DeploySummaryMailer.weekly_summary(user, organization, summary_data)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["nick@shipyrd.io"], email.from
    assert_equal [user.email], email.to
    assert_equal "Shipyrd: Weekly deploy summary for #{organization.name}", email.subject
  end

  test "html part includes prose summary" do
    email = DeploySummaryMailer.weekly_summary(user, organization, summary_data)
    html = email.html_part.body.decoded

    assert_match organization.name, html
    assert_match "shipped", html
    assert_match "my-app", html
    assert_match "3 deploys", html
    assert_match "production", html
    assert_match "staging", html
    assert_match "8 minutes shipping", html
    assert_match "Nick", html
    assert_match "Rehan", html
    assert_match(/2 more deploys.*than the week before/, html)
    assert_match "Keep shipping", html
  end

  test "text part includes prose summary" do
    email = DeploySummaryMailer.weekly_summary(user, organization, summary_data)
    text = email.text_part.body.decoded

    assert_match organization.name, text
    assert_match "shipped", text
    assert_match "my-app", text
    assert_match "3 deploys", text
    assert_match "production", text
    assert_match "8 minutes shipping", text
    assert_match "Nick", text
    assert_match "Rehan", text
    assert_match "2 more deploys than the week before", text
    assert_match "Keep shipping", text
  end
end
