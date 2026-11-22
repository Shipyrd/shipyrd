require "test_helper"

class DestinationDeployStateTest < ActiveSupport::TestCase
  setup do
    @application = create(:application_with_repository_url)
  end

  test "fills in the deploy state a destination row reads" do
    destination = create(:destination, application: @application, name: "production", branch: "main")
    first = deploy("aaa1111", status: "post-deploy")
    second = deploy("bbb2222", status: "post-deploy")

    preloaded = DestinationDeployState.preload(@application.destinations.where(id: destination.id)).first

    assert_no_queries do
      assert_equal second, preloaded.latest_deploy
      assert_equal second, preloaded.latest_post_deploy
      assert_equal first, preloaded.latest_deploy.previous_deploy
      assert_equal "#{@application.repository_url}/compare/aaa1111...bbb2222", preloaded.latest_deploy.compare_url
      assert_equal "#{@application.repository_url}/compare/bbb2222...main", preloaded.on_deck_url
    end
  end

  test "skips the latest deploy when looking for the one to compare against" do
    create(:destination, application: @application, name: "production")
    settled = deploy("aaa1111", status: "post-deploy")
    in_flight = deploy("bbb2222", status: "pre-deploy")

    preloaded = DestinationDeployState.preload(@application.destinations).first

    assert_no_queries do
      assert_equal in_flight, preloaded.latest_deploy
      assert_equal settled, preloaded.latest_post_deploy
      # `previous_deploy` is the newest post-deploy other than the deploy
      # itself, and the deploy in flight is not one.
      assert_equal settled, preloaded.latest_deploy.previous_deploy
    end
  end

  test "leaves a destination with no deploys alone" do
    create(:destination, application: @application, name: "staging")

    preloaded = DestinationDeployState.preload(@application.destinations).first

    assert_no_queries do
      assert_nil preloaded.latest_deploy
      assert_nil preloaded.latest_post_deploy
      assert_nil preloaded.on_deck_url
    end
  end

  test "keeps each destination's deploys to itself" do
    create(:destination, application: @application, name: "production")
    create(:destination, application: @application, name: "staging")
    deploy("prod111", destination: "production", status: "post-deploy")
    deploy("stag222", destination: "staging", status: "post-deploy")

    by_name = DestinationDeployState.preload(@application.destinations.order(:name)).index_by(&:name)

    assert_no_queries do
      assert_equal "prod111", by_name["production"].latest_deploy.version
      assert_equal "stag222", by_name["staging"].latest_deploy.version
    end
  end

  test "costs the same number of queries however many destinations there are" do
    one = create(:destination, application: @application, name: "production")
    deploy("aaa1111", status: "post-deploy")
    deploy("bbb2222", status: "post-deploy")

    one_destination = count_queries { render_state(@application.destinations.where(id: one.id)) }

    %w[staging canary demo].each do |name|
      create(:destination, application: @application, name: name)
      deploy("ccc3333", destination: name, status: "post-deploy")
      deploy("ddd4444", destination: name, status: "post-deploy")
    end

    four_destinations = count_queries { render_state(@application.destinations) }

    assert_equal one_destination, four_destinations,
      "deploy state should be batch-loaded, not queried per destination"
  end

  private

  def deploy(version, destination: "production", status: "post-deploy")
    create(:deploy, application: @application, destination: destination, status: status, version: version)
  end

  # Everything the destination partials read off a preloaded destination.
  def render_state(destinations)
    preloaded = DestinationDeployState.preload(destinations)

    preloaded.each do |destination|
      destination.on_deck_url
      destination.latest_deploy&.compare_url
    end
  end
end
