json.user do
  json.extract! @user, :id, :name, :email
  json.display_name @user.display_name
end

json.organizations @organizations do |organization|
  json.extract! organization, :id, :name
  json.active_subscription organization.active_subscription?
  json.admin organization.admin?(@user)
end
