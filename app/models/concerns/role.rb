module Role
  extend ActiveSupport::Concern

  included do
    enum :role, user: 0, admin: 1
  end
end
