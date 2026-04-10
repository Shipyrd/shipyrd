require "test_helper"

class WeeklyDeploySummaryJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  let(:organization) { create(:organization) }
  let(:application) { create(:application, organization: organization) }
  let(:user) { create(:user) }

  setup do
    ENV["COMMUNITY_EDITION"] = "0"
    create(:membership, user: user, organization: organization)
  end

  teardown do
    ENV.delete("COMMUNITY_EDITION")
  end

  def create_completed_deploy(app: application, age_in_days: 1)
    deploy = create(:deploy, application: app, status: "post-deploy", service_version: "app@#{SecureRandom.hex(6)}")
    deploy.update_column(:created_at, age_in_days.days.ago)
    deploy
  end

  describe "community edition" do
    it "does not send emails on community edition" do
      ENV["COMMUNITY_EDITION"] = "1"
      create_completed_deploy

      assert_no_emails do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end
  end

  describe "user preferences" do
    it "skips users who opted out of weekly deploy summary" do
      user.update!(weekly_deploy_summary: false)
      create_completed_deploy

      assert_no_emails do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end
  end

  describe "sending summaries" do
    it "sends an email to each user in an organization with deploys" do
      second_user = create(:user)
      create(:membership, user: second_user, organization: organization)
      create_completed_deploy

      assert_emails 2 do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end

    it "skips organizations with no deploys in the period" do
      create_completed_deploy(age_in_days: 10)

      assert_no_emails do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end

    it "only includes post-deploy status deploys" do
      create(:deploy, application: application, status: "pre-deploy", service_version: "app@#{SecureRandom.hex(6)}")

      assert_no_emails do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end

    it "only includes deploys from the last 7 days" do
      create_completed_deploy(age_in_days: 8)

      assert_no_emails do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end

    it "skips organizations with no deploys in the past month" do
      create_completed_deploy(age_in_days: 31)

      assert_no_emails do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end
    end

    it "scopes deploys per organization" do
      other_org = create(:organization)
      other_app = create(:application, organization: other_org)
      other_user = create(:user)
      create(:membership, user: other_user, organization: other_org)

      create_completed_deploy
      create_completed_deploy(app: other_app)

      assert_emails 2 do
        perform_enqueued_jobs do
          WeeklyDeploySummaryJob.perform_now
        end
      end

      delivered = ActionMailer::Base.deliveries.last(2)
      subjects = delivered.map(&:subject)
      assert subjects.include?("Shipyrd: Weekly deploy summary for #{organization.name}")
      assert subjects.include?("Shipyrd: Weekly deploy summary for #{other_org.name}")
    end
  end
end
