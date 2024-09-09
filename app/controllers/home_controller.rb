# frozen_string_literal: true

# HomeController is responsible for handling requests to the home page.
class HomeController < ApplicationController
  def index
    return if current_user.nil?

    if current_user.settings_incomplete?
      redirect_to user_settings_path
    else
      current_user.data_sources.count.zero? ? redirect_to(new_data_source_path) : redirect_to('/query')
    end
  end

  def swatch; end
end
