# frozen_string_literal: true

# spec/controllers/home_controller_spec.rb

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    context 'when there is no current_user' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'when current_user is present' do
      let(:user) { create(:user) }
      let(:data_source) { create(:data_source, user:) }

      before do
        sign_in user
        allow(controller).to receive(:current_user).and_return(user)
        allow(DataSource).to receive(:active).and_return(DataSource.none)
        allow(DatabaseService).to receive(:test_connection).with(data_source).and_return(true)
        allow(controller).to receive(:user_signed_in?).and_return(true)
      end

      context 'when user settings are complete' do
        it 'returns a successful response' do
          get :index
          expect(response).to redirect_to('/query')
        end
      end
    end
  end
end
