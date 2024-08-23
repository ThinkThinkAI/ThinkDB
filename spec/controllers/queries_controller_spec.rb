# frozen_string_literal: true

require 'rails_helper'
require 'faker'

RSpec.describe QueriesController, type: :controller do
  let(:user) { create(:user) }
  let(:active_data_source) { create(:data_source, connected: true, user:) }
  let(:valid_attributes) do
    { name: Faker::Lorem.sentence, sql: 'SELECT * FROM users', data_source_id: active_data_source.id }
  end
  let(:invalid_attributes) { { name: '', sql: '' } }

  let(:database_service_mock) { instance_double('DatabaseService', build_tables: true) }

  before do
    sign_in user
    allow_any_instance_of(DataSource).to receive(:build_tables_if_connected).and_return(nil)
    allow(user).to receive(:connected_data_source).and_return(active_data_source)
    allow(DataSource).to receive(:find).and_return(active_data_source)
    allow(DatabaseService).to receive(:new).and_return(database_service_mock)
  end

  let!(:query) { create(:query, valid_attributes) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'returns a not success response' do
      allow_any_instance_of(User).to receive(:connected_data_source).and_return(nil)
      get :index
      expect(response).not_to be_successful
    end
  end

  describe 'GET #show' do
    let(:mock_database_service) { instance_double(DatabaseService) }

    before do
      allow(DatabaseService).to receive(:build).and_return(mock_database_service)
    end

    it 'returns a success response' do
      get :show, params: { id: query.to_param }
      expect(response).to be_successful
    end

    it 'returns a success response with multiple selects' do
      query.update(sql: 'SELECT * FROM users;SELECT * FROM users')
      query.reload
      allow(mock_database_service).to receive(:run_raw_query).with('SELECT * FROM users').and_return(%w[id name])
      get :show, params: { id: query.to_param }
      expect(response).to be_successful
    end

    it 'returns a success response sql modification' do
      query.update(sql: 'DELETE USERS')
      query.reload
      allow(mock_database_service).to receive(:run_raw_query).with(query.sql).and_return(0)
      get :show, params: { id: query.to_param }
      expect(response).to be_successful
    end

    it 'returns a success even if exception' do
      query.update(sql: 'DELETE USERS')
      query.reload
      allow(mock_database_service).to receive(:run_raw_query).with(query.sql).and_raise(StandardError)
      get :show, params: { id: query.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Query' do
        expect do
          post :create,
               params: { name: Faker::Lorem.sentence, sql: 'SELECT * FROM users',
                         data_source_id: active_data_source.id }
        end.to change(Query, :count).by(1)
      end

      it 'redirects to the created query' do
        post :create,
             params: { name: Faker::Lorem.sentence, sql: 'SELECT * FROM users', data_source_id: active_data_source.id }
        newly_created_query = Query.last
        expect(response).to redirect_to(data_source_query_path(newly_created_query.data_source, newly_created_query))
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e., to display the "new" template)' do
        post :create, params: { query: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { id: query.to_param, sql: 'select * from something' } }

      it 'updates the requested query' do
        put :update, params: new_attributes
        query.reload
        expect(query.sql).to eq('select * from something')
      end

      it 'returns a JSON response with a success message' do
        patch :update, params: { id: query.id, sql: new_attributes[:sql] }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Query was updated.' })
      end
    end

    context 'with invalid params' do
      it 'does not update the query' do
        patch :update, params: { id: query.id, sql: nil }, format: :json
        query.reload
        expect(query.sql).not_to eq(nil)
      end

      it 'returns a JSON response with an error message' do
        patch :update, params: { id: query.id, sql: nil }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Query was not updated' })
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested query' do
      expect do
        delete :destroy, params: { id: query.to_param }, format: :json
      end.to change(Query, :count).by(-1)
    end

    it 'returns a JSON response with a success message' do
      delete :destroy, params: { id: query.to_param }, format: :json
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'message' => 'Query was successfully destroyed' })
    end
  end

  describe 'GET #metadata' do
    let(:mock_database_service) { instance_double(DatabaseService) }
    let!(:query) { create(:query) }

    before do
      allow(DatabaseService).to receive(:build).and_return(mock_database_service)
    end

    context 'successful response' do
      it 'returns metadata for a query' do
        allow(mock_database_service).to receive(:count).with(query.sql).and_return(1)
        allow(mock_database_service).to receive(:column_names).with(query.sql).and_return(%w[id name])

        get :metadata, params: { id: query.to_param, sql: query.sql }, format: :json
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')

        response_json = JSON.parse(response.body)
        expect(response_json['total_records']).to eq(1)
        expect(response_json['column_names']).to eq(%w[id name])
      end
    end

    context 'with an exception' do
      it 'returns an error response' do
        allow(mock_database_service).to receive(:count).with(query.sql).and_raise(StandardError.new('Database error'))

        get :metadata, params: { id: query.to_param, sql: query.sql }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        response_json = JSON.parse(response.body)
        expect(response_json['failure']).to eq('Database error')
      end
    end
  end

  describe 'GET #data' do
    let(:mock_database_service) { instance_double(DatabaseService) }
    let!(:query) { create(:query) }

    before do
      allow(DatabaseService).to receive(:build).and_return(mock_database_service)
    end

    context 'successful response' do
      it 'returns data for a query' do
        allow(mock_database_service).to receive(:run_query).and_return([{ 'id' => 1, 'name' => 'Test User' }])

        get :data, params: { id: query.to_param, sql: query.sql, page: 1, results_per_page: 10 }, format: :json
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')

        response_json = JSON.parse(response.body)
        expect(response_json.first['id']).to eq(1)
        expect(response_json.first['name']).to eq('Test User')
      end
    end

    context 'with an exception' do
      it 'returns an error response' do
        allow(mock_database_service).to receive(:run_query).with(any_args).and_raise(StandardError.new('Query error'))

        get :data, params: { id: query.to_param, sql: query.sql, page: 1, results_per_page: 10 }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')

        response_json = JSON.parse(response.body)
        expect(response_json['failure']).to eq('Query error')
      end
    end
  end

  private

  def response_json
    JSON.parse(response.body)
  end
end
