# frozen_string_literal: true

# HomeController is responsible for handling requests to the home page.
class HomeController < ApplicationController
  def index
    return if current_user.nil?

    if current_user.settings_incomplete?
      redirect_to user_settings_path
    else
      redirect_to data_sources_path
    end
  end

  def swatch; end
end
