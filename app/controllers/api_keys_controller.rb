class ApiKeysController < ApplicationController
  before_action :set_api_key, only: %i[destroy]

  # GET /api_keys or /api_keys.json
  def index
    @api_keys = ApiKey.all
  end

  # POST /api_keys or /api_keys.json
  def create
    @api_key = ApiKey.new

    respond_to do |format|
      if @api_key.save!
        format.html { redirect_to api_key_url(@api_key), notice: "Api key was successfully created." }
        format.json { render :show, status: :created, location: @api_key }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_keys/1 or /api_keys/1.json
  def destroy
    @api_key.destroy

    respond_to do |format|
      format.html { redirect_to api_keys_url, notice: "Api key was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_api_key
    @api_key = ApiKey.find(params[:id])
  end
end
