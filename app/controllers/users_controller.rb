# frozen_string_literal: true

# The UsersController manages user-related actions and ensures that a
# user is authenticated before accessing any actions within the controller.
# It typically includes actions like show, edit, update, and destroy for
# user profiles.
class UsersController < ApplicationController
  before_action :authenticate_user!

  def settings
    @user = current_user
    return unless request.patch? && @user.update(user_params)

    redirect_to root_path, notice: 'User configuration updated successfully.'
  end

  private

  def user_params
    params.require(:user).permit(:ai_url, :ai_model, :ai_api_key, :darkmode)
  end
end
