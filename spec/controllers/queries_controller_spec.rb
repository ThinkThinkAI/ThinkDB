require 'rails_helper'

RSpec.describe QueriesController, type: :controller do
  let(:user) { create(:user) }
  let(:active_data_source) { create(:data_source, connected: true, user:) }
  let(:valid_attributes) do
    { name: 'Test Query', sql: 'SELECT * FROM users', data_source_id: active_data_source.id }
  end
  let(:invalid_attributes) { { name: '', sql: '' } }
  let!(:query) { create(:query, valid_attributes) }
  let(:mock_database_service) { instance_double('DatabaseService') }

  before do
    sign_in user
    allow(user).to receive(:connected_data_source).and_return(active_data_source)
    allow(DatabaseService).to receive(:build).with(active_data_source).and_return(mock_database_service)
  end

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
    it 'returns a success response' do
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
          post :create, params:  valid_attributes
        end.to change(Query, :count).by(1)
      end

      it 'redirects to the created query' do
        post :create, params: valid_attributes
        expect(response).to redirect_to(Query.last)
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
      let(:new_attributes) { { id: query.to_param, name: 'Updated Query' } }

      it 'updates the requested query' do
        put :update, params: new_attributes
        query.reload
        expect(query.name).to eq('Updated Query')
      end

      it 'redirects to the query' do
        put :update, params: { id: query.to_param, query: valid_attributes }
        expect(response).to redirect_to(query)
      end
    end

    context 'with invalid params' do
      it 'returns a success response to display the "edit" template' do
        put :update, params: { id: query.to_param, name: '', sql: '' }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested query' do
      expect do
        delete :destroy, params: { id: query.to_param }
      end.to change(Query, :count).by(-1)
    end

    it 'redirects to the queries list' do
      delete :destroy, params: { id: query.to_param }
      expect(response).to redirect_to(queries_url)
    end
  end

  describe 'GET #metadata' do
    context 'successful response' do
      it 'returns metadata for a query' do
        allow(mock_database_service).to receive(:count).and_return(1)
        allow(mock_database_service).to receive(:column_names).and_return(%w[id name])

        get :metadata, params: { id: query.to_param, sql: query.sql }
        expect(response).to be_successful
        expect(response_json['total_records']).to eq(1)
        expect(response_json['column_names']).to eq(%w[id name])
      end
    end

    context 'with an exception' do
      it 'returns an error response' do
        allow(mock_database_service).to receive(:count).and_raise(StandardError.new('Database error'))

        get :metadata, params: { id: query.to_param, sql: query.sql }
        expect(response_json['failure']).to eq('Database error')
      end
    end
  end

  describe 'GET #data' do
    context 'successful response' do
      it 'returns data for a query' do
        allow(mock_database_service).to receive(:run_query).and_return([{ 'id' => 1, 'name' => 'Test User' }])

        get :data, params: { id: query.to_param, sql: query.sql, page: 1, page_size: 10 }
        expect(response).to be_successful
        expect(response_json.first['id']).to eq(1)
        expect(response_json.first['name']).to eq('Test User')
      end
    end

    context 'with an exception' do
      it 'returns an error response' do
        allow(mock_database_service).to receive(:run_query).and_raise(StandardError.new('Query error'))

        get :data, params: { id: query.to_param, sql: query.sql, page: 1, page_size: 10 }
        expect(response_json['failure']).to eq('Query error')
      end
    end
  end

  private

  def response_json
    JSON.parse(response.body)
  end
end
