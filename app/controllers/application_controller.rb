# frozen_string_literal: true

# ApplicationController is the base controller for all other controllers in the application.
# It includes common application-wide behaviors and settings.
class ApplicationController < ActionController::Base
  before_action :check_requirements, unless: :excluded_paths?

  private

  def check_requirements
    return unless user_signed_in?

    # Check user settings first and redirect if necessary
    if current_user.settings_incomplete? && !on_user_settings_path?
      redirect_to user_settings_path, alert: 'Please complete your settings.'
      return
    end

    # Check data sources next and redirect if necessary
    return unless current_user.data_sources.blank? && !on_new_data_source_path?

    redirect_to new_data_source_path, alert: 'Please create a data source.'
    nil
  end

  def connect_first_data_source
    first_data_source = current_user.data_sources.first
    if first_data_source
      first_data_source.update(connected: true)
      first_data_source
    else
      redirect_to new_data_source_path, alert: 'Please create a data source.'
      nil
    end
  end

  def on_user_settings_path?
    request.path == user_settings_path
  end

  def on_new_data_source_path?
    request.path == new_data_source_path
  end

  def excluded_paths?
    request.path == user_settings_path ||
      (controller_name == 'data_sources' && %w[new create].include?(action_name))
  end
end
