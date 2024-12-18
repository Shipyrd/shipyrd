require "test_helper"
require "helpers/basic_auth_helpers"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
    @admin_user = create(:user)
    @organization.memberships.create(user: @admin_user, role: :admin)
    sign_in @admin_user.email, @admin_user.password
  end

  test "should get edit" do
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch organization_url(@organization), params: {organization: {name: "New Name"}}
    assert_redirected_to edit_organization_url(@organization)
    @organization.reload
    assert_equal "New Name", @organization.name
  end

  test "should redirect if organization id does not match current organization" do
    another_organization = create(:organization)
    get edit_organization_url(another_organization)
    assert_redirected_to edit_organization_path(@organization)
  end
end
