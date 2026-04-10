class WeeklyDeploySummaryJob < ApplicationJob
  def perform
    return unless ENV["COMMUNITY_EDITION"] == "0"

    period_end = Time.current
    period_start = 7.days.ago

    Organization.find_each do |organization|
      next unless recent_activity?(organization, period_end)

      deploys = completed_deploys(organization, period_start, period_end)
      next if deploys.empty?

      summary_data = build_summary(deploys, organization, period_start, period_end)

      organization.users.where(weekly_deploy_summary: true).find_each do |user|
        DeploySummaryMailer.weekly_summary(user, organization, summary_data).deliver_later
      end
    end
  end

  private

  def recent_activity?(organization, period_end)
    Deploy.joins(:application)
      .where(applications: {organization_id: organization.id})
      .where(status: "post-deploy")
      .where(created_at: 30.days.until(period_end)..period_end)
      .exists?
  end

  def completed_deploys(organization, period_start, period_end)
    Deploy.joins(:application)
      .where(applications: {organization_id: organization.id})
      .where(status: "post-deploy")
      .where(created_at: period_start..period_end)
      .order(created_at: :desc)
  end

  def build_summary(deploys, organization, period_start, period_end)
    unordered = deploys.reorder("")

    app_totals = unordered.joins(:application)
      .group("applications.name")
      .count

    app_destination_counts = unordered.joins(:application)
      .where.not(destination: nil)
      .group("applications.name", :destination)
      .count

    app_runtimes = unordered.joins(:application)
      .group("applications.name")
      .sum(:runtime)

    apps = {}
    app_totals.each do |app_name, count|
      apps[app_name] = {total: count, runtime: 0, destinations: []}
    end

    app_destination_counts.each do |(app_name, destination), count|
      apps[app_name][:destinations] << [destination, count]
    end

    app_runtimes.each do |app_name, runtime|
      apps[app_name][:runtime] = runtime || 0
    end

    apps.each_value do |data|
      data[:destinations].sort_by! { |_, v| -v }
    end

    deployers = unordered.group(:performer).count
      .sort_by { |_, v| -v }
      .map { |performer, count| [User.lookup_performer(organization.id, performer), count] }

    this_week_count = unordered.count
    previous_week_count = completed_deploys(organization, period_start - 7.days, period_start).count

    {
      total_deploys: this_week_count,
      previous_week_deploys: previous_week_count,
      applications: apps.sort_by { |_, v| -v[:total] },
      deployers: deployers,
      period_start: period_start,
      period_end: period_end
    }
  end
end
