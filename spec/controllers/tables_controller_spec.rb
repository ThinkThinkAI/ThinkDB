# spec/controllers/tables_controller_spec.rb
require 'rails_helper'

RSpec.describe TablesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source) }
  let(:table) { create(:table, data_source:) }
  let(:database_service) { instance_double(DatabaseService) }

  before do
    sign_in user
    allow(controller).to receive(:check_requirements)

    allow(DatabaseService).to receive(:build).and_return(database_service)
    allow(database_service).to receive(:all_records_query)
    allow(database_service).to receive(:table_structure_query)
    allow(database_service).to receive(:build_tables)
  end

  describe 'GET #show' do
    it 'assigns the requested table to @table' do
      get :show, params: { data_source_id: data_source.friendly_id, id: table.friendly_id }
      expect(assigns(:table)).to eq(table)
    end

    it 'assigns @all_records_query' do
      expected_query = "SELECT * FROM #{table.name}"
      allow(database_service).to receive(:all_records_query).with(table.name).and_return(expected_query)
      get :show, params: { data_source_id: data_source.friendly_id, id: table.friendly_id }
      expect(assigns(:all_records_query)).to eq(expected_query)
    end

    it 'assigns @table_structure_query' do
      expected_query = "DESCRIBE #{table.name}"
      allow(database_service).to receive(:table_structure_query).with(table.name).and_return(expected_query)
      get :show, params: { data_source_id: data_source.friendly_id, id: table.friendly_id }
      expect(assigns(:table_structure_query)).to eq(expected_query)
    end
  end
end
