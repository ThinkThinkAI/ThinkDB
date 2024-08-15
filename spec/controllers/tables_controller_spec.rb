# frozen_string_literal: true

# spec/controllers/tables_controller_spec.rb

require 'rails_helper'

RSpec.describe TablesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }
  let(:table) { create(:table, data_source:) }

  # Mock the database service
  let(:database_service_mock) do
    instance_double('DatabaseService', all_records_query: [], table_structure_query: [], build_tables: nil)
  end

  before do
    sign_in user
    allow(DatabaseService).to receive(:build).and_return(database_service_mock)
    allow(DataSource).to receive(:friendly).and_return(double(find: data_source))
    allow(data_source.tables).to receive(:friendly).and_return(double(find: table))
  end

  describe 'GET #show' do
    it 'assigns the requested table to @table' do
      get :show, params: { data_source_id: data_source.id, id: table.id }
      expect(assigns(:table)).to eq(table)
    end

    it 'assigns the result of the all_records_query to @all_records_query' do
      get :show, params: { data_source_id: data_source.id, id: table.id }
      expect(assigns(:all_records_query)).to eq([])
    end

    it 'assigns the result of the table_structure_query to @table_structure_query' do
      get :show, params: { data_source_id: data_source.id, id: table.id }
      expect(assigns(:table_structure_query)).to eq([])
    end

    it 'calls the all_records_query method on the database service' do
      get :show, params: { data_source_id: data_source.id, id: table.id }
      expect(database_service_mock).to have_received(:all_records_query).with(table.name)
    end

    it 'calls the table_structure_query method on the database service' do
      get :show, params: { data_source_id: data_source.id, id: table.id }
      expect(database_service_mock).to have_received(:table_structure_query).with(table.name)
    end

    it 'renders the show template' do
      get :show, params: { data_source_id: data_source.id, id: table.id }
      expect(response).to render_template(:show)
    end
  end
end
