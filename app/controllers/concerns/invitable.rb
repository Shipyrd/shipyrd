module Invitable
  extend ActiveSupport::Concern

  included do
    before_action :store_invite_code
  end

  private

  def invite_code
    session[:invite_code]
  end

  def store_invite_code
    session[:invite_code] = params[:code] if params[:code].present?
  end

  def load_invite_link
    @invite_link = InviteLink.active.find_by(code: invite_code)

    return unless community_edition?

    redirect_to new_session_url if Organization.count.positive? && @invite_link.blank?
  end
end
