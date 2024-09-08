require "test_helper"

class ConnectionTest < ActiveSupport::TestCase
  let(:application) { build(:application_with_repository_url) }

  describe "connects_successfully" do
    it "fails if invalid token" do
      connection = build(:connection, provider: :github, key: "invalid", application: application)

      stub_request(:get, "https://api.github.com/repos/kevin/bacon/contents/config/deploy.yml?access_token=invalid").to_return(status: 401)

      refute connection.valid?
    end

    it "sets last_connected_at on success" do
      connection = build(:connection, provider: :github, key: "valid", application: application)

      Github::Client::Repos::Contents.any_instance.stubs(:find).returns(OpenStruct.new(content: Base64.encode64("content")))

      assert connection.valid?
      assert connection.last_connected_at
    end
  end

  describe "import_deploy_recipes" do
    setup do
      Destination.any_instance.stubs(:process_recipe)
      @destination = create(:destination, application: application, name: nil)
      @connection = build(:connection, provider: :github, key: "valid", application: application)
    end

    it "fails gracefully if no recipe" do
      stub_request(:get, "https://api.github.com/repos/kevin/bacon/contents/config/deploy.yml?access_token=valid").to_return(status: 404)

      @connection.import_deploy_recipes

      refute @connection.application.destinations.first.recipe
    end

    it "saves the recipe" do
      Github::Client::Repos::Contents.any_instance.stubs(:find).returns(OpenStruct.new(content: Base64.encode64("recipe")))

      @connection.import_deploy_recipes

      # When we just have the default destination that's the base_recipe, the destination specific recipe
      # is then layered on if we have an actual destination such as staging or production.
      refute @connection.application.destinations.first.recipe
      assert_equal "recipe", @connection.application.destinations.first.base_recipe
      assert @connection.application.destinations.first.recipe_updated_at
    end

    it "saves destination specific recipes" do
      @destination.update!(name: "production")
      @connection.stubs(:fetch_repository_content).with("config/deploy.production.yml").returns("production recipe")
      @connection.stubs(:fetch_repository_content).with("config/deploy.yml").returns("base recipe")

      @connection.import_deploy_recipes

      assert_equal "production recipe", @connection.application.destinations.first.recipe
      assert_equal "base recipe", @connection.application.destinations.first.base_recipe
    end
  end
end
