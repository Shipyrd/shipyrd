class DeploySummaryMailer < ApplicationMailer
  def weekly_summary(user, organization, summary_data)
    @user = user
    @organization = organization
    @total_deploys = summary_data[:total_deploys]
    @previous_week_deploys = summary_data[:previous_week_deploys]
    @applications = summary_data[:applications]
    @deployers = summary_data[:deployers]
    @period_start = summary_data[:period_start]
    @period_end = summary_data[:period_end]
    @unsubscribe_url = unsubscribe_url(user.generate_token_for(:unsubscribe))

    mail to: @user.email, subject: "Shipyrd: Weekly deploy summary for #{@organization.name}"
  end
end
