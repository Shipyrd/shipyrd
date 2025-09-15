class ChannelsController < ApplicationController
  before_action :set_application
  before_action :set_channel

  def edit
  end

  def update
    respond_to do |format|
      if @channel.update(channel_params)
        flash[:notice] = "#{@channel.display_name} connection was successfully updated."
        format.html { redirect_to edit_application_path(@channel.application) }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @application = @channel.application
    @channel.destroy!

    redirect_to edit_application_path(@application)
  end

  private

  def set_application
    @application = current_organization.applications.find(params[:application_id])
  end

  def set_channel
    @channel = @application.channels.find(params[:id])
  end

  def channel_params
    params.require(:channel).permit(events: [])
  end
end
