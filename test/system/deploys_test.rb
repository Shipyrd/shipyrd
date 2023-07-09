require "application_system_test_case"

class DeploysTest < ApplicationSystemTestCase
  setup do
    @deploy = deploys(:one)
  end

  test "visiting the index" do
    visit deploys_url
    assert_selector "h1", text: "Deploys"
  end

  test "should create deploy" do
    visit deploys_url
    click_on "New deploy"

    fill_in "Command", with: @deploy.command
    fill_in "Deployed at", with: @deploy.deployed_at
    fill_in "Deployer", with: @deploy.deployer
    fill_in "Destination", with: @deploy.destination
    fill_in "Hosts", with: @deploy.hosts
    fill_in "Role", with: @deploy.role
    fill_in "Runtime", with: @deploy.runtime
    fill_in "Service version", with: @deploy.service_version
    fill_in "Status", with: @deploy.status
    fill_in "Subcommand", with: @deploy.subcommand
    fill_in "Version", with: @deploy.version
    click_on "Create Deploy"

    assert_text "Deploy was successfully created"
    click_on "Back"
  end

  test "should update Deploy" do
    visit deploy_url(@deploy)
    click_on "Edit this deploy", match: :first

    fill_in "Command", with: @deploy.command
    fill_in "Deployed at", with: @deploy.deployed_at
    fill_in "Deployer", with: @deploy.deployer
    fill_in "Destination", with: @deploy.destination
    fill_in "Hosts", with: @deploy.hosts
    fill_in "Role", with: @deploy.role
    fill_in "Runtime", with: @deploy.runtime
    fill_in "Service version", with: @deploy.service_version
    fill_in "Status", with: @deploy.status
    fill_in "Subcommand", with: @deploy.subcommand
    fill_in "Version", with: @deploy.version
    click_on "Update Deploy"

    assert_text "Deploy was successfully updated"
    click_on "Back"
  end

  test "should destroy Deploy" do
    visit deploy_url(@deploy)
    click_on "Destroy this deploy", match: :first

    assert_text "Deploy was successfully destroyed"
  end
end
