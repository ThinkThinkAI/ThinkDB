# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataSourcesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }
  let(:database_service_mock) { instance_double('DatabaseService', build_tables: true) }

  before do
    sign_in(user)
    allow(DatabaseService).to receive(:build).and_return(database_service_mock)
  end

  describe 'GET #show' do
    it 'redirects to data sources index' do
      get :show, params: { id: data_source.to_param }
      expect(response).to redirect_to(data_sources_path)
    end
  end

  describe 'GET #new' do
    it 'assigns a new data_source' do
      get :new
      expect(assigns(:data_source)).to be_a_new(DataSource)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new data source' do
        expect do
          post :create, params: { data_source: attributes_for(:data_source) }
        end.to change(user.data_sources, :count).by(1)
        expect(response).to redirect_to('/query')
      end
    end

    context 'with invalid params' do
      it 're-renders the new template' do
        allow_any_instance_of(DataSource).to receive(:save).and_return(false)
        post :create, params: { data_source: { name: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested data_source' do
      get :edit, params: { id: data_source.to_param }
      expect(assigns(:data_source)).to eq(data_source)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid params' do
      it 'updates the requested data_source' do
        patch :update, params: { id: data_source.to_param, data_source: { name: 'Updated Name' } }
        data_source.reload
        expect(data_source.name).to eq('Updated Name')
        expect(response).to redirect_to('/query')
      end
    end

    context 'with invalid params' do
      it 're-renders the edit template' do
        allow_any_instance_of(DataSource).to receive(:update).and_return(false)
        patch :update, params: { id: data_source.to_param, data_source: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when other data sources exist' do
      before { create(:data_source, user:) }

      it 'destroys the requested data_source and redirects to /query' do
        data_source # create the data source before invoking the destroy action
        expect do
          delete :destroy, params: { id: data_source.to_param }
        end.to change(user.data_sources, :count).by(-1)

        expect(response).to redirect_to('/query')
      end
    end

    context 'when no other data sources exist' do
      it 'destroys the requested data_source and redirects to new data source path' do
        data_source # create the data source before invoking the destroy action
        expect do
          delete :destroy, params: { id: data_source.to_param }
        end.to change(user.data_sources, :count).by(-1)

        expect(response).to redirect_to(new_data_source_path)
      end
    end
  end

  describe 'PATCH #connect' do
    context 'successful update' do
      it 'toggles the connection status of the data source' do
        patch :connect, params: { id: data_source.id }
        data_source.reload

        expect(response).to redirect_to('/query')
      end
    end

    context 'failure to update' do
      before do
        allow(data_source).to receive(:update!).and_raise(StandardError.new('Connection error'))
        allow_any_instance_of(DataSourcesController).to receive(:set_data_source).and_return(data_source)
      end

      it 'returns an error response for JSON format' do
        patch :connect, params: { id: data_source.to_param }, as: :json
        JSON.parse(response.body)
        expect(response.status).to eq(200)
      end
    end
  end
end
