# app/controllers/custom_sessions_controller.rb
# frozen_string_literal: true
class CustomSessionsController < Devise::SessionsController
  # GET /resource/sign_in
  def new
    redirect_to root_path
  end
end
