# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'PATCH #settings' do
    context 'with valid params' do
      let(:valid_params) do
        {
          user: {
            ai_url: 'http://example.com',
            ai_model: 'model-v1',
            ai_api_key: '123abc',
            darkmode: true
          }
        }
      end

      it 'updates user settings and redirects' do
        patch :settings, params: valid_params
        user.reload
        expect(user.ai_url).to eq('http://example.com')
        expect(user.ai_model).to eq('model-v1')
        expect(user.ai_api_key).to eq('123abc')
        expect(user.darkmode).to be_truthy
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('User configuration updated successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          user: {
            ai_url: '',
            ai_model: '',
            ai_api_key: '',
            darkmode: nil
          }
        }
      end

      it 'does not update user settings and re-renders the settings page' do
        patch :settings, params: invalid_params
        user.reload

        expect(user.darkmode).not_to be_nil
      end
    end
  end
end
