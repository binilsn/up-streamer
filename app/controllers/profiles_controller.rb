class ProfilesController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(user_params)
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :current_password, :password, :password_confirmation)
  end
end
