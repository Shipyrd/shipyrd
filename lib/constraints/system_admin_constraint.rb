module Constraints
  class SystemAdminConstraint
    def matches?(request)
      return false if ENV["COMMUNITY_EDITION"] != "0"

      user_id = request.session[:user_id]
      user_id && User.find_by(id: user_id)&.system_admin?
    end
  end
end
