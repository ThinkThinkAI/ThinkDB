# frozen_string_literal: true

# spec/controllers/home_controller_spec.rb

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    context 'when there is no current_user' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful # equivalent to expect(response.status).to eq(200)
      end
    end

    context 'when current_user is present' do
      let(:user) { create(:user) }

      before { sign_in user }

      context 'when user settings are incomplete' do
        before do
          allow_any_instance_of(User).to receive(:settings_incomplete?).and_return(true)
        end

        it 'redirects to user settings path' do
          get :index
          expect(response).to redirect_to(user_settings_path)
        end
      end

      context 'when user settings are complete' do
        before do
          allow(user).to receive(:settings_incomplete?).and_return(false)
        end

        it 'redirects to data sources path' do
          get :index
          expect(response).to redirect_to(new_data_source_path)
        end
      end
    end
  end
end
