require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
  end

  describe "display_name" do
    it "returns name if present" do
      destination = build(:destination)

      assert_equal "default", destination.display_name

      destination.name = ""
      assert_equal "default", destination.display_name

      destination.name = "production"
      assert_equal "production", destination.display_name
    end
  end

  describe "key pairs" do
    it "generates on create" do
      destination = create(:destination, application: @application, name: "test")

      assert destination.private_key
      assert destination.public_key
    end

    it "generates if missing" do
      destination = create(:destination, application: @application, name: "test")

      destination.update_columns(
        private_key: nil,
        public_key: nil
      )

      destination.update!(url: "http://example.com")

      assert destination.private_key
      assert destination.public_key
    end
  end

  describe "process_recipe" do
    let(:destination) { create(:destination, name: "production", application: @application) }

    it "creates a new server based on recipes" do
      base_recipe = {
        service: "shipyrd",
        image: "shipyrd/shipyrd",
        registry: {
          username: "shipyrd",
          password: "KAMAL_REGISTRY_PASSWORD"
        }
      }.deep_stringify_keys.to_yaml
      destination.update!(base_recipe: base_recipe)

      recipe = {
        servers: {
          web: {
            hosts: ["123.456.789.0"]
          }
        }
      }.deep_stringify_keys.to_yaml

      assert_difference -> { destination.servers.count }, 1 do
        destination.update(
          recipe: recipe
        )
      end

      assert_no_difference -> { destination.servers.count }, 1 do
        destination.recipe_will_change!
        destination.save!
      end
    end
  end

  it "new_servers_available?" do
    destination = create(:destination, application: @application)

    refute destination.new_servers_available?

    server = destination.servers.create!(host: "123.456.789.0")

    assert destination.reload.new_servers_available?

    server.update!(last_connected_at: Time.current)

    refute destination.new_servers_available?
  end
end
