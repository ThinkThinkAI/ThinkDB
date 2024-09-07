# frozen_string_literal: true

# spec/controllers/custom_sessions_controller_spec.rb
require 'rails_helper'

RSpec.describe CustomSessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end
