# frozen_string_literal: true

# ApplicationHelper module provides helper methods to be used in views across
# the entire application.
module ApplicationHelper
  def text_muted
    'text-muted' unless connected?
  end

  def connected?
    user_signed_in? && current_user.connected_data_source.present?
  end
end
