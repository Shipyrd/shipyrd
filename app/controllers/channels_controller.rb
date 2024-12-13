class ChannelsController < ApplicationController
  before_action :set_channel

  def edit
  end

  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to edit_channel_path(@channel), notice: "#{@channel.display_name} connection was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_channel
    @channel = current_organization.channels.find(params[:id])
  end

  def channel_params
    params.require(:channel).permit(events: [])
  end
end
