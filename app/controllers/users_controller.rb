class UsersController < ApplicationController
  include Invitable

  skip_before_action :authenticate, only: %i[new create]

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
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if invite_code && @invite_link.blank?
        @user.errors.add(:base, "Invalid invite link")

        format.html { render :new, status: :unprocessable_content }
      elsif @user.password.present? && @user.save
        organization = @invite_link&.organization || Organization.create!(name: @user.organization_name)
        organization.memberships.create(
          user: @user,
          role: @invite_link ? @invite_link.role : :admin
        )

        reset_session
        session[:user_id] = @user.id

        format.html { redirect_to root_url, notice: "User was successfully created." }
      else
        @user.errors.add(:password, "can't be blank") if @user.password.blank?

        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "Account successfully updated." }
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
      :password
    )
  end
end
