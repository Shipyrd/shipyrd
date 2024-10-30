class UsersController < ApplicationController
  skip_before_action :authenticate, only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_user_url, alert: "Try again later." }

  before_action :set_user, only: %i[show edit update destroy]
  before_action :require_self, only: %i[edit update]
  before_action :require_admin, only: %i[index destroy]

  def index
    @users = User.has_role
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
    invite_link = InviteLink.active.find_by(code: params[:code])

    respond_to do |format|
      if invite_link.present? && @user.save
        @user.update(role: invite_link.role)

        cookies.signed[:user_id] = @user.id

        format.html { redirect_to root_url, notice: "User was successfully created." }
      else
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
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :username,
      :email,
      :name,
      :password
    )
  end
end
