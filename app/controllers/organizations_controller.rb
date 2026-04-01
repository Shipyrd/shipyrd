class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[edit update]
  before_action :require_admin, only: %i[edit update]

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      @organization.memberships.create!(user: current_user, role: :admin)
      session[:organization_id] = @organization.id
      redirect_to root_path, notice: "Organization created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def switch
    organization = current_user.organizations.find_by(id: params[:id])

    if organization
      session[:organization_id] = organization.id
      redirect_to root_path, notice: "Switched to #{organization.name}"
    else
      redirect_to root_path, alert: "Organization not found"
    end
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to edit_organization_url(@organization), notice: "Organization settings successfully updated."
    else
      render :edit
    end
  end

  private

  def set_organization
    @organization = current_organization

    redirect_to edit_organization_path(@organization) if params[:id] != @organization.id.to_s
  end

  # Only allow a list of trusted parameters through.
  def organization_params
    params.require(:organization).permit(:name, :time_zone, :business_hours_start, :business_hours_end)
  end
end
