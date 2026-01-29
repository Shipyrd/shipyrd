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

  describe "switching organizations" do
    setup do
      @organization2 = create(:organization, name: "Organization 2")
      @organization.memberships.create(user: @admin_user)
      @organization2.memberships.create(user: @admin_user)
    end

    test "should switch to valid organization" do
      get root_url
      initial_org_id = session[:organization_id]

      post switch_organization_path(@organization2)

      assert_redirected_to root_path
      assert_equal @organization2.id, session[:organization_id]
      assert_equal "Switched to Organization 2", flash[:notice]
      refute_equal initial_org_id, session[:organization_id]
    end

    test "should not switch to organization user is not a member of" do
      get root_url
      other_organization = create(:organization, name: "Other Organization")

      post switch_organization_path(other_organization)

      assert_redirected_to root_path
      assert_nil session[:organization_id]
      assert_equal "Organization not found", flash[:alert]
    end

    test "should update current_organization after switching" do
      post switch_organization_path(@organization2)

      get root_url

      assert_response :success
      assert_equal @organization2.id, session[:organization_id]
    end
  end
end
