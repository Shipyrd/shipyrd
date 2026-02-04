class BadgeController < ApplicationController
  skip_before_action :authenticate, only: [:show]
  before_action :load_destination

  def deploy
    respond_to do |format|
      format.json
    end
  end

  def lock
    respond_to do |format|
      format.json
    end
  end

  private

  def load_destination
    application = Application.find_by(badge_key: params[:application_id])
    @destination = application.destinations.find_by(
      name: params[:id] == "default" ? nil : params[:id]
    )
  end
end
