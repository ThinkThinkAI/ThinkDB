# spec/controllers/tables_controller_spec.rb

require 'rails_helper'

RSpec.describe TablesController, type: :controller do
  let(:data_source) { create(:data_source) }
  let(:table) { create(:table, data_source: data_source) }
  let(:database_service) { instance_double(DatabaseService) }

  before do
    allow(DataSource).to receive(:friendly).and_return(DataSource)
    allow(DataSource).to receive(:find).with(data_source.id.to_s).and_return(data_source)
    allow(DatabaseService).to receive(:build).with(data_source).and_return(database_service)
    allow(database_service).to receive(:all_records_query).with(table.name).and_return("SELECT * FROM #{table.name}")
    allow(database_service).to receive(:table_structure_query).with(table.name).and_return("DESCRIBE #{table.name}")
    allow(data_source.tables).to receive(:friendly).and_return(data_source.tables)
    allow(data_source.tables).to receive(:find).with(table.id.to_s).and_return(table)
  end

  describe 'GET #show' do
    before do
      get :show, params: { data_source_id: data_source.id, id: table.id }
    end

    it 'assigns the requested data_source to @data_source' do
      expect(assigns(:data_source)).to eq(data_source)
    end

    it 'assigns the requested table to @table' do
      expect(assigns(:table)).to eq(table)
    end

    it 'initializes the database service' do
      expect(assigns(:database_service)).to eq(database_service)
    end

    it 'sets @all_records_query' do
      expect(assigns(:all_records_query)).to eq("SELECT * FROM #{table.name}")
    end

    it 'sets @table_structure_query' do
      expect(assigns(:table_structure_query)).to eq("DESCRIBE #{table.name}")
    end
  end
end
