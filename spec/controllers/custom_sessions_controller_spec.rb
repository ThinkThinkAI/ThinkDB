# spec/controllers/custom_sessions_controller_spec.rb
require 'rails_helper'

RSpec.describe CustomSessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'GET #new' do
    it 'redirects to the root path' do
      get :new
      expect(response).to redirect_to(root_path)
    end
  end
end
