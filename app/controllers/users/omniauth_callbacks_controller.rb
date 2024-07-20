# frozen_string_literal: true

module Users
  # OmniauthCallbacksController handles callbacks from Omniauth providers.
  # It is responsible for handling authentication responses from providers
  # like GitHub, Google, Facebook, etc., and signing in or registering users
  # in the system.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'GitHub') if is_navigational_format?
      else
        session['devise.github_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to root_path
      end
    end

    def failure
      redirect_to root_path
    end
  end
end
