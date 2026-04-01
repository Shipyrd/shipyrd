require "test_helper"

class CleanupOldDeploysJobTest < ActiveSupport::TestCase
  let(:application) { create(:application) }

  def create_deploy(age_in_days:)
    deploy = create(:deploy, application: application, service_version: "app@#{SecureRandom.hex(6)}")
    deploy.update_column(:created_at, age_in_days.days.ago)
    deploy
  end

  describe "cleanup" do
    it "deletes deploys older than 90 days" do
      old_deploy = create_deploy(age_in_days: 91)
      recent_deploy = create_deploy(age_in_days: 30)

      # Ensure more than MINIMUM_KEPT total
      12.times { create_deploy(age_in_days: 1) }

      CleanupOldDeploysJob.perform_now

      refute Deploy.exists?(old_deploy.id)
      assert Deploy.exists?(recent_deploy.id)
    end

    it "keeps the last 10 deploys even if all are older than 90 days" do
      deploys = 12.times.map { |i| create_deploy(age_in_days: 100 + i) }

      CleanupOldDeploysJob.perform_now

      assert_equal 10, application.deploys.count
      # The 2 oldest should be deleted
      refute Deploy.exists?(deploys.last.id)
      refute Deploy.exists?(deploys[-2].id)
    end

    it "does not delete anything when there are fewer than 10 deploys" do
      5.times { create_deploy(age_in_days: 100) }

      assert_no_difference("Deploy.count") do
        CleanupOldDeploysJob.perform_now
      end
    end

    it "does not delete recent deploys" do
      5.times { create_deploy(age_in_days: 10) }

      assert_no_difference("Deploy.count") do
        CleanupOldDeploysJob.perform_now
      end
    end

    it "scopes cleanup per application" do
      other_app = create(:application)
      old_deploy = create_deploy(age_in_days: 100)
      12.times { create_deploy(age_in_days: 1) }

      other_old = create(:deploy, application: other_app, service_version: "app@#{SecureRandom.hex(6)}")
      other_old.update_column(:created_at, 100.days.ago)

      CleanupOldDeploysJob.perform_now

      refute Deploy.exists?(old_deploy.id)
      # other_app only has 1 deploy (< MINIMUM_KEPT), so it's kept
      assert Deploy.exists?(other_old.id)
    end
  end
end
