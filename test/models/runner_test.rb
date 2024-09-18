require "test_helper"

class RunnerTest < ActiveSupport::TestCase
  setup do
    @application = build(:application)
    @destination = build(:destination, application: @application, base_recipe: {service: :shipyrd}.to_yaml)
    @runner = build(:runner, destination: @destination)
  end

  it "knows the time it took" do
    refute @runner.time
    @runner.started_at = 1.minute.ago
    @runner.finished_at = Time.current

    assert_equal 60, @runner.time
  end

  describe "run!" do
    it "runs a command successfully" do
      @runner.command = "lock status"

      @destination.stubs(:with_recipe).yields("config")

      cmd = mock
      cmd.expects(:run).yields("output", "error")
      @runner.stubs(:cmd).returns(cmd)

      @runner.run!

      assert @runner.started_at
      assert @runner.finished_at
      assert_equal "kamal lock status --config-file config/deploy.yml", @runner.full_command
      assert_equal "output", @runner.output
    end

    it "stores the error when it fails" do
      @runner.command = "lock status"

      cmd = mock
      cmd.expects(:run).yields("output", "error")
      @runner.stubs(:cmd).returns(cmd)

      @runner.run!

      assert_equal "error", @runner.error
    end
  end

  describe "cli_options" do
    it "based on destination" do
      assert_equal "--config-file tmp/config/deploy.yml", @runner.cli_options("tmp/config")

      @destination.update(name: :production)

      assert_equal "--destination production --config-file tmp/config/deploy.yml", @runner.cli_options("tmp/config")
    end
  end
end
