class RunnersController < ApplicationController
  before_action :require_admin, only: [:create]
  before_action :set_application
  before_action :set_destination
  before_action :set_runner, only: [:show]

  def index
    @runners = @destination.runners.order("created_at DESC")
  end

  def new
    @runner = @destination.runners.new(command: params[:command])
  end

  def create
    @runner = @destination.runners.new(runner_params)

    if @runner.save
      respond_to do |format|
        format.html { redirect_to application_destination_runner_path(@application, @destination, @runner) }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application
    @application = Application.find(params[:application_id])
  end

  def set_destination
    @destination = @application.destinations.find(params[:destination_id])
  end

  def set_runner
    @runner = @destination.runners.find(params[:id])
  end

  def runner_params
    params.require(:runner).permit(:command)
  end
end
