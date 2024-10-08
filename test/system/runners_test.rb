require "application_system_test_case"
require "helpers/basic_auth_helpers"

class DestinationsTest < ApplicationSystemTestCase
  setup do
    @api_key = ApiKey.create!
  end

  describe "with an existing destination" do
    setup do
      @application = create(:application_with_repository_url)
      @destination = create(:destination, application: @application)
    end

    test "prefills the command field when provided" do
      visit basic_auth_url(root_url, @api_key.token)

      visit new_application_destination_runner_path(@application, @destination, command: "app logs")

      assert_field "Command to run", with: "app logs"
    end

    test "shows error output if command failed completely" do
      visit basic_auth_url(root_url, @api_key.token)
      visit new_application_destination_runner_path(@application, @destination, command: "unknown-command")

      click_on "Run command"

      Runner.any_instance.stubs(:run!)
      assert_text "Running unknown-command"
      Runner.last.update(error: "failed with")

      visit application_destination_runner_path(@application, @destination, Runner.last)

      assert_text "failed with"
    end

    test "running command" do
      visit basic_auth_url(root_url, @api_key.token)
      visit application_destination_path(@application, @destination)

      refute_text "Run command on default"

      @destination.servers.create(host: "123.456.78.9", last_connected_at: Time.current)

      visit application_destination_path(@application, @destination)

      click_on "Run command"

      fill_in "Command", with: "lock status"
      click_on "Run command"

      assert_text "Running lock status"
    end
  end
end
