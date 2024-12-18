class OrganizationsController < ApplicationController
  before_action :set_organization
  before_action :require_admin

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
    params.require(:organization).permit(:name)
  end
end
