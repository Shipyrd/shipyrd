class UsersController < ApplicationController
  skip_before_action :authenticate, only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_url, alert: "Try again later." }

  before_action :set_user, only: %i[show edit update destroy]
  before_action :require_self, only: %i[edit update]
  before_action :require_admin, only: %i[index destroy]

  def index
    @users = current_organization.users
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    invite_link = InviteLink.active.find_by(code: params[:code]) if params[:code]

    @user = User.new(user_params)

    respond_to do |format|
      if params[:code] && invite_link.blank?
        @user.errors.add(:base, "Invalid invite link")

        format.html { render :new, status: :unprocessable_entity }
      elsif @user.password.present? && @user.save
        organization = invite_link&.organization || Organization.create!(name: @user.organization_name)

        @user.update(role: invite_link ? invite_link.role : :admin)
        organization.users << @user

        cookies.signed[:user_id] = @user.id

        format.html { redirect_to root_url, notice: "User was successfully created." }
      else
        @user.errors.add(:password, "can't be blank") if @user.password.blank?

        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "Account successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!

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
      :username,
      :email,
      :name,
      :password
    )
  end
end
