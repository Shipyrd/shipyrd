class IncomingWebhooksController < ApplicationController
  before_action :set_application
  before_action :validate_provider, only: %i[new]
  before_action :set_incoming_webhook, only: %i[destroy]

  # GET /incoming_webhooks/new
  def new
    @incoming_webhook = @application.incoming_webhooks.new(provider: params[:provider])
  end

  # POST /incoming_webhooks or /incoming_webhooks.json
  def create
    @incoming_webhook = @application.incoming_webhooks.new(incoming_webhook_params)

    respond_to do |format|
      if @incoming_webhook.save
        format.html { redirect_to edit_application_url(@application), notice: "Incoming webhook was successfully created." }
        format.json { render :show, status: :created, location: @incoming_webhook }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @incoming_webhook.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /incoming_webhooks/1 or /incoming_webhooks/1.json
  def destroy
    @incoming_webhook.destroy!

    respond_to do |format|
      format.html { redirect_to edit_application_url(@application), notice: "Incoming webhook was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def validate_provider
    raise "Invalid provider" unless IncomingWebhook.providers.key?(params[:provider])
  end

  def set_application
    @application = current_organization.applications.find(params[:application_id])
  end

  def set_incoming_webhook
    @incoming_webhook = @application.incoming_webhooks.find(params.expect(:id))
  end

  def incoming_webhook_params
    params.expect(incoming_webhook: [:provider, :token])
  end
end
