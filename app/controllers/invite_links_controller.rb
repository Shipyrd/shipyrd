class InviteLinksController < ApplicationController
  def create
    @invite_link = InviteLink.new(invite_link_params)

    respond_to do |format|
      if @invite_link.save
        format.html { redirect_to users_path, notice: "Invite link was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invite_link = InviteLink.find(params[:id])
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
