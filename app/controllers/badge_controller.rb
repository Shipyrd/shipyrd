class BadgeController < ApplicationController
  skip_before_action :authenticate, only: [:show]

  def show
    application = Application.find_by(badge_key: params[:application_id])
    @destination = application.destinations.find_by(name: params[:id])

    respond_to do |format|
      format.json
    end
  end
end
