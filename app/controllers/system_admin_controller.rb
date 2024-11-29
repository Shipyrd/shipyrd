class SystemAdminController < ApplicationController
  before_action :require_system_admin

  def require_system_admin
    redirect_to main_app.root_path and return unless current_user.system_admin?
  end
end
