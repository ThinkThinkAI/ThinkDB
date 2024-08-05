# frozen_string_literal: true

# spec/controllers/data_sources_controller_spec.rb
require 'rails_helper'

RSpec.describe DataSourcesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }

  before { sign_in user }

  describe 'GET #index' do
    it 'assigns all data sources to @data_sources' do
      get :index
      expect(assigns(:data_sources)).to eq(user.data_sources)
    end
  end

  describe 'GET #show' do
    it 'redirects to data_sources_path' do
      get :show, params: { id: data_source.id }
      expect(response).to redirect_to(data_sources_path)
    end
  end

  describe 'GET #new' do
    it 'assigns a new data source to @data_source' do
      get :new
      expect(assigns(:data_source)).to be_a_new(DataSource)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new data source' do
        expect do
          post :create, params: { data_source: attributes_for(:data_source) }
        end.to change(user.data_sources, :count).by(1)
      end

      it 'redirects to queries_path' do
        post :create, params: { data_source: attributes_for(:data_source) }
        expect(response).to redirect_to(queries_path)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new data source' do
        expect do
          post :create, params: { data_source: attributes_for(:data_source, name: nil) }
        end.not_to change(DataSource, :count)
      end

      it 're-renders the :new template with unprocessable_entity status' do
        post :create, params: { data_source: attributes_for(:data_source, name: nil) }
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested data source to @data_source' do
      get :edit, params: { id: data_source.id }
      expect(assigns(:data_source)).to eq(data_source)
    end
  end

  describe 'PUT #update' do
    context 'with valid attributes' do
      it 'updates the data source' do
        put :update, params: { id: data_source.id, data_source: { name: 'Updated Name' } }
        data_source.reload
        expect(data_source.name).to eq('Updated Name')
        expect(response).to redirect_to(queries_path)
      end
    end

    context 'with invalid attributes' do
      it 'does not update the data source' do
        put :update, params: { id: data_source.id, data_source: { name: nil } }
        data_source.reload
        expect(data_source.name).not_to be_nil
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    before { data_source } # Create a data source before running delete tests

    context 'when other data sources exist' do
      let!(:other_data_source) { create(:data_source, user:) }

      it 'deletes the data source' do
        expect do
          delete :destroy, params: { id: data_source.id }
        end.to change(DataSource, :count).by(-1)
      end

      it 'redirects to queries_path' do
        delete :destroy, params: { id: data_source.id }
        expect(response).to redirect_to(queries_path)
      end
    end

    context 'when no other data sources exist' do
      it 'redirects to new_data_source_path' do
        delete :destroy, params: { id: data_source.id }
        expect(response).to redirect_to(new_data_source_path)
        expect(flash[:notice]).to eq('No DataSource left. Please create a new one.')
      end
    end
  end

  describe 'POST #connect' do
    let(:database_service) { instance_double(DatabaseService) }

    before do
      allow(DatabaseService).to receive(:build).and_return(database_service)
      allow(database_service).to receive(:build_tables)
    end

    context 'when connection is successful' do
      it 'redirects to queries_path with a success message' do
        post :connect, params: { id: data_source.id }
        expect(response).to redirect_to(queries_path)
        expect(flash[:notice]).to eq('DataSource connection status was successfully updated.')
      end

      it 'returns a JSON response with a success message' do
        post :connect, params: { id: data_source.id }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('message' => 'DataSource connection status was successfully updated.')
      end
    end

    context 'when updated_status connection fails' do
      let(:error_message) { 'Updated status Failed' }

      before do
        data_source.update(connected: false)
        expect_any_instance_of(DataSource).to receive(:update!).and_raise(StandardError, error_message)
      end

      it 'redirects to data_sources_path with an error message' do
        post :connect, params: { id: data_source.id }
        expect(response).to redirect_to(data_sources_path)
        expect(flash[:alert]).to eq("Failed to update DataSource connection: #{error_message}")
      end

      it 'returns a JSON response with an error message' do
        post :connect, params: { id: data_source.id }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('message' => error_message)
      end
    end
  end

  private

  def sign_in(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
