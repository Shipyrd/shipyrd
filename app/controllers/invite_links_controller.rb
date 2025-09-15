class InviteLinksController < ApplicationController
  before_action :require_admin

  def create
    @invite_link = current_organization.invite_links.new(invite_link_params)

    respond_to do |format|
      if @invite_link.save
        format.html { redirect_to users_path, notice: "Invite link was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @invite_link = current_organization.invite_links.find(params[:id])
    @invite_link.deactivate!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "Invite link was successfully deactivated." }
    end
  end

  private

  def invite_link_params
    params.require(:invite_link).permit(:role)
  end
end
