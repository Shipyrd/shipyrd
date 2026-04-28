class UsersController < ApplicationController
  include Invitable

  skip_before_action :authenticate, only: %i[new create]
  skip_before_action :check_email_verification, only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_url, alert: "Try again later." }

  before_action :set_user, only: %i[show edit update destroy]
  before_action :require_self, only: %i[edit update]
  before_action :require_admin, only: %i[index destroy]
  before_action :load_invite_link, only: %i[new create]

  def index
    @memberships = current_organization.memberships.includes(:user)
  end

  def show
  end

  def new
    if current_user && @invite_link.present?
      @invite_link.accept!(current_user)
      flash[:notice] = "Welcome to #{@invite_link.organization.name}!"
      session[:organization_id] = @invite_link.organization.id
      redirect_to root_url
    else
      @user = User.new
    end
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if invite_code && @invite_link.blank?
        @user.errors.add(:base, "Invalid invite link")

        format.html { render :new, status: :unprocessable_content }
      elsif @user.password.blank?
        @user.errors.add(:password, "can't be blank")

        format.html { render :new, status: :unprocessable_content }
      elsif (organization = create_user_with_organization)
        UserMailer.email_verification(@user).deliver_later

        reset_session
        session[:user_id] = @user.id

        ahoy.track "user_signed_up", user_id: @user.id, organization_id: organization.id

        format.html { redirect_to root_url }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to edit_user_url(@user), notice: "Settings saved." }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    current_organization.memberships.find_by(user: @user).destroy

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
    end
  end

  private

  def create_user_with_organization
    ApplicationRecord.transaction do
      @user.save!
      if @invite_link
        @invite_link.accept!(@user)
        @invite_link.organization
      else
        org = Organization.create!(name: @user.organization_name)
        org.memberships.create!(user: @user, role: :admin)
        org
      end
    end
  rescue ActiveRecord::RecordInvalid
    nil
  rescue InviteLink::AlreadyRedeemed
    @user.errors.add(:base, "Invite link is no longer valid")
    nil
  end

  def require_self
    redirect_to root_path unless @user.id == current_user.id
  end

  def set_user
    @user = current_organization.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :organization_name,
      :email,
      :name,
      :password,
      :weekly_deploy_summary
    )
  end
end
