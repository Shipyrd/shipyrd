class CleanupOldDeploysJob < ApplicationJob
  RETENTION_DAYS = 90
  MINIMUM_KEPT = 10

  def perform
    Application.find_each do |application|
      keep_ids = application.deploys.order(created_at: :desc).limit(MINIMUM_KEPT).pluck(:id)

      application.deploys
        .where("created_at < ?", RETENTION_DAYS.days.ago)
        .where.not(id: keep_ids)
        .delete_all
    end
  end
end
