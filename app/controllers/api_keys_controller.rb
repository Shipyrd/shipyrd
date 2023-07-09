class ApiKeysController < ApplicationController
  before_action :set_api_key, only: %i[ show edit update destroy ]

  # GET /api_keys or /api_keys.json
  def index
    @api_keys = ApiKey.all
  end

  # GET /api_keys/1 or /api_keys/1.json
  def show
  end

  # GET /api_keys/new
  def new
    @api_key = ApiKey.new
  end

  # GET /api_keys/1/edit
  def edit
  end

  # POST /api_keys or /api_keys.json
  def create
    @api_key = ApiKey.new(api_key_params)

    respond_to do |format|
      if @api_key.save
        format.html { redirect_to api_key_url(@api_key), notice: "Api key was successfully created." }
        format.json { render :show, status: :created, location: @api_key }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api_keys/1 or /api_keys/1.json
  def update
    respond_to do |format|
      if @api_key.update(api_key_params)
        format.html { redirect_to api_key_url(@api_key), notice: "Api key was successfully updated." }
        format.json { render :show, status: :ok, location: @api_key }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_keys/1 or /api_keys/1.json
  def destroy
    @api_key.destroy!

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

    # Only allow a list of trusted parameters through.
    def api_key_params
      params.require(:api_key).permit(:token)
    end
end
