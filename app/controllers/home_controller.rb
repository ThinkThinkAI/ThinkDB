# frozen_string_literal: true

# HomeController is responsible for handling requests to the home page.
class HomeController < ApplicationController
  def index
    return if current_user.nil?

    redirect_to('/query')
  end

  def swatch; end
end
