class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[edit update disconnect_slack]
  before_action :require_admin, only: %i[edit update disconnect_slack]

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    ActiveRecord::Base.transaction do
      @organization.save!
      @organization.memberships.create!(user: current_user, role: :admin)
    end

    session[:organization_id] = @organization.id
    redirect_to root_path, notice: "Organization created successfully"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
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

  def disconnect_slack
    ActiveRecord::Base.transaction do
      @organization.memberships.update_all(slack_user_id: nil)
      @organization.update!(
        slack_team_id: nil,
        slack_team_name: nil,
        slack_access_token: nil
      )
    end

    redirect_to edit_organization_url(@organization), notice: "Slack workspace disconnected."
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
