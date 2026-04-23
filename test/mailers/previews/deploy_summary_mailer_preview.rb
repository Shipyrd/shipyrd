class DeploySummaryMailerPreview < ActionMailer::Preview
  def weekly_summary
    user = User.first || User.new(name: "Jane Doe", email: "jane@example.com")
    organization = Organization.first || Organization.new(name: "Acme Corp")

    summary_data = {
      total_deploys: 12,
      previous_week_deploys: 8,
      applications: [
        ["web", {total: 7, runtime: 840, destinations: [["production", 5], ["staging", 2]]}],
        ["api", {total: 3, runtime: 360, destinations: [["production", 2], ["staging", 1]]}],
        ["workers", {total: 2, runtime: 150, destinations: [["production", 2]]}]
      ],
      deployers: [["Nick", 8], ["Rehan", 3], ["Sarah", 1]],
      period_start: 7.days.ago,
      period_end: Time.current
    }

    DeploySummaryMailer.weekly_summary(user, organization, summary_data)
  end
end
