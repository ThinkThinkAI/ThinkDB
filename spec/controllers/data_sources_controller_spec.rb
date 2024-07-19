# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataSourcesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: data_source.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:new_attributes) { { name: 'New DataSource Name' } }

      it 'updates the data source' do
        patch :update, params: { id: data_source.id, data_source: new_attributes }
        data_source.reload
        expect(data_source.name).to eq('New DataSource Name')
      end

      it 'redirects to the data sources index' do
        patch :update, params: { id: data_source.id, data_source: new_attributes }
        expect(response).to redirect_to(data_sources_path)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { { adapter: '' } }

      it 'does not update the data source' do
        patch :update, params: { id: data_source.id, data_source: invalid_attributes }
        data_source.reload
        expect(data_source.adapter).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the data source' do
      data_source
      expect do
        delete :destroy, params: { id: data_source.id }
      end.to change(DataSource, :count).by(-1)
    end

    it 'redirects to the data sources index' do
      delete :destroy, params: { id: data_source.id }
      expect(response).to redirect_to(data_sources_path)
    end
  end

  describe 'GET #connect' do
    it 'toggles the connection status of the data source' do
      initial_status = data_source.connected
      get :connect, params: { id: data_source.id }
      data_source.reload
      expect(data_source.connected).to eq(!initial_status)
    end

    it 'redirects to the data sources index' do
      get :connect, params: { id: data_source.id }
      expect(response).to redirect_to(data_sources_path)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:valid_attributes) { attributes_for(:data_source) }

      it 'creates a new data source' do
        expect do
          post :create, params: { data_source: valid_attributes }
        end.to change(DataSource, :count).by(1)
      end

      it 'redirects to the data sources index' do
        post :create, params: { data_source: valid_attributes }
        expect(response).to redirect_to(data_sources_path)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { attributes_for(:data_source, adapter: '') }

      it 'does not create a new data source' do
        expect do
          post :create, params: { data_source: invalid_attributes }
        end.not_to change(DataSource, :count)
      end
    end
  end

  describe 'GET #show' do
    it 'redirects to the data sources index' do
      get :show, params: { id: data_source.id }
      expect(response).to redirect_to(data_sources_path)
    end
  end
end
