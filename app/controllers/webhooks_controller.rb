class WebhooksController < ApplicationController
  before_action :set_application

  def new
    @webhook = @application.webhooks.new
  end

  def create
    @webhook = @application.webhooks.new(webhook_params)
    @webhook.user = current_user

    if @webhook.save
      respond_to do |format|
        format.html { redirect_to edit_application_url(@application), notice: "Webhook was successfully created." }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  private

  def set_application
    @application = current_organization.applications.find(params[:application_id])
  end

  def set_webhook
    @webhook = @application.webhooks.find(params[:id])
  end

  def webhook_params
    params.require(:webhook).permit(
      :url
    )
  end
end
