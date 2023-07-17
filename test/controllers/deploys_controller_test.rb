require "test_helper"

class DeploysControllerTest < ActionDispatch::IntegrationTest
  setup do
    skip
    @deploy = deploys(:one)
  end

  test "should get index" do
    get deploys_url
    assert_response :success
  end

  test "should get new" do
    get new_deploy_url
    assert_response :success
  end

  test "should create deploy" do
    assert_difference("Deploy.count") do
      post deploys_url, params: {deploy: {command: @deploy.command, deployed_at: @deploy.deployed_at, deployer: @deploy.deployer, destination: @deploy.destination, hosts: @deploy.hosts, role: @deploy.role, runtime: @deploy.runtime, service_version: @deploy.service_version, status: @deploy.status, subcommand: @deploy.subcommand, version: @deploy.version}}
    end

    assert_redirected_to deploy_url(Deploy.last)
  end

  test "should show deploy" do
    get deploy_url(@deploy)
    assert_response :success
  end

  test "should get edit" do
    get edit_deploy_url(@deploy)
    assert_response :success
  end

  test "should update deploy" do
    patch deploy_url(@deploy), params: {deploy: {command: @deploy.command, deployed_at: @deploy.deployed_at, deployer: @deploy.deployer, destination: @deploy.destination, hosts: @deploy.hosts, role: @deploy.role, runtime: @deploy.runtime, service_version: @deploy.service_version, status: @deploy.status, subcommand: @deploy.subcommand, version: @deploy.version}}
    assert_redirected_to deploy_url(@deploy)
  end

  test "should destroy deploy" do
    assert_difference("Deploy.count", -1) do
      delete deploy_url(@deploy)
    end

    assert_redirected_to deploys_url
  end
end
