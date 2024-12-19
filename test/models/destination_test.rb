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

  it "lock/unlock" do
    destination = create(:destination, application: @application)
    user = create(:user)

    freeze_time do
      destination.expects(:dispatch_notifications).with(:lock, {locked_at: Time.current, user_id: user.id})

      destination.lock!(user)
    end

    assert destination.locked?
    assert_equal user, destination.locker
    assert destination.locked_at

    destination.expects(:dispatch_notifications).with(:unlock, {user_id: user.id})

    destination.unlock!(user)

    refute destination.locked?
    refute destination.locker
    refute destination.locked_at
  end

  it "dispatch_notifications" do
    destination = create(:destination, application: @application)
    user = create(:user)
    webhook = @application.webhooks.create!(user: user, url: "http://example.com")
    channel = webhook.channel
    event = :lock

    assert_difference -> { channel.notifications.count }, 1 do
      destination.dispatch_notifications(event, {test: "test"})
    end

    notification = channel.notifications.last

    assert_equal event, notification.event
    assert_equal({"test" => "test"}, notification.details)
  end

  describe "on_deck_url" do
    it "is nil if hasn't been successfully deployed" do
      create(:deploy,
        service_version: "shipyrd@123",
        application: @application,
        version: "123",
        status: "pre-build",
        command: :deploy)

      Application.last.update(
        repository_url: "https://github.com/shipyrd/shipyrd"
      )

      refute Destination.last.on_deck_url
    end

    it "is nil if last deploy was uncommitted" do
      create(:deploy,
        service_version: "shipyrd@123",
        application: @application,
        version: "123_uncommitted",
        status: "post-deploy",
        command: :deploy)

      @application.update(
        repository_url: "https://github.com/shipyrd/shipyrd"
      )

      refute Destination.last.on_deck_url
    end

    it "returns a compare URL" do
      create(:deploy,
        application: @application,
        service_version: "shipyrd@123",
        version: "123",
        status: "post-deploy",
        command: :deploy)

      @application.update(
        repository_url: "https://github.com/shipyrd/shipyrd"
      )

      destination = Destination.last

      assert_equal "https://github.com/shipyrd/shipyrd/compare/123...main", destination.on_deck_url

      destination.update(branch: nil)
      refute destination.on_deck_url
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

  describe "with_recipe" do
    setup do
      @destination = create(:destination, application: @application, base_recipe: {service: :shipyrd}.to_yaml)
    end

    it "writes to temp folder with SSH config" do
      # Stubbing this to ensure the directory is removed after using
      dir = "tmp/#{SecureRandom.stubs(:hex).returns("random")}"

      @destination.with_recipe do |config_dir|
        recipe = YAML.load_file("#{config_dir}/deploy.yml")

        assert recipe["ssh"]["keys_only"]
        assert_equal recipe["ssh"]["key_data"], [@destination.private_key]
      end

      refute File.directory?(dir)
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

      assert destination.recipe_last_processed_at

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
