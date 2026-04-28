require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  let(:application) { create(:application, key: "bacon") }

  describe "display_name" do
    it "prefers name over slug" do
      application.name = "Bacon"
      assert_equal "Bacon", application.display_name

      application.name = nil
      assert_equal application.slug, application.display_name

      application.name = ""
      assert_equal application.slug, application.display_name
    end
  end

  describe "slug" do
    it "auto-populates from the name on save" do
      application = build(:application, name: "Pizza Tracker", slug: nil)
      application.valid?

      assert_equal "pizza-tracker", application.slug
    end

    it "preserves a user-provided slug" do
      application = build(:application, name: "Pizza Tracker", slug: "pt")
      application.valid?

      assert_equal "pt", application.slug
    end

    it "rejects invalid slug formats" do
      application = build(:application, slug: "Not Valid!")

      refute application.valid?
      assert_includes application.errors[:slug].first, "lowercase"
    end

    it "appends a counter when a generated slug would collide" do
      organization = create(:organization)
      create(:application, organization: organization, name: "Same Name")
      sibling = create(:application, organization: organization, name: "Same Name")

      assert_equal "same-name-2", sibling.slug
    end

    it "enforces uniqueness within an organization" do
      organization = create(:organization)
      create(:application, organization: organization, slug: "shared")
      duplicate = build(:application, organization: organization, slug: "shared")

      refute duplicate.valid?
      assert_includes duplicate.errors[:slug], "has already been taken"
    end

    it "allows the same slug across organizations" do
      create(:application, slug: "shared", organization: create(:organization))
      sibling = build(:application, slug: "shared", organization: create(:organization))

      assert sibling.valid?
    end
  end

  describe "repo parts from URL" do
    let(:application) { build(:application, repository_url: "https://github.com/nickhammond/ham") }

    it "knows the username" do
      assert_equal "nickhammond", application.repository_username
    end

    it "knows the repository name" do
      assert_equal "ham", application.repository_name
    end
  end

  describe "destinations" do
    let(:service_version) { "#{application.key}@123" }

    it "fetches destinations from known deploys" do
      create(:deploy, service_version: service_version, destination: :production, application: application)
      create(:deploy, service_version: service_version, destination: :staging, application: application)

      assert_equal ["production", "staging"], application.reload.destination_names
    end

    it "adds in a default destination name" do
      create(:deploy, service_version: service_version, application: application)
      create(:deploy, service_version: service_version, destination: :production, application: application)

      assert_equal [nil, "production"], application.reload.destination_names
    end
  end

  describe "current_status" do
    it "fetches latest deploy status" do
      create(
        :deploy,
        application: application,
        status: "pre-build",
        command: :deploy,
        destination: :staging
      )
      create(
        :deploy,
        application: application,
        status: "post-deploy",
        command: :deploy,
        destination: :staging
      )
      create(
        :deploy,
        application: application,
        status: nil,
        command: :app,
        subcommand: :info,
        destination: :staging
      )

      assert_equal "post-deploy", application.current_status(destination: :staging)
    end
  end
end
