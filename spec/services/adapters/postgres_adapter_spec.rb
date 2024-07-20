# frozen_string_literal: true

require 'rails_helper'
require 'pg'
require './app/services/adapters/postgres_adapter'

RSpec.describe PostgresAdapter, type: :model do
  let(:data_source) do
    instance_double('DataSource', {
                      database: 'test_db',
                      username: 'user',
                      password: 'password',
                      host: 'localhost',
                      port: '5432'
                    })
  end

  let(:connection) { instance_double(PG::Connection) }
  let(:result) { instance_double(PG::Result) }
  let(:adapter) { PostgresAdapter.new(data_source) }

  before do
    allow(PG).to receive(:connect).and_return(connection)
  end

  describe '#get_schemas' do
    let(:expected_rows) do
      [
        { 'table_name' => 'users', 'column_name' => 'id', 'data_type' => 'integer' },
        { 'table_name' => 'users', 'column_name' => 'name', 'data_type' => 'varchar' }
      ]
    end

    before do
      allow(connection).to receive(:exec).with('SELECT table_name, column_name, data_type FROM information_schema.columns').and_return(expected_rows)
    end

    it 'retrieves schemas from the database' do
      schemas = adapter.get_schemas

      expected_result = {
        'users' => [
          { column_name: 'id', data_type: 'integer' },
          { column_name: 'name', data_type: 'varchar' }
        ]
      }

      expect(schemas).to eq(expected_result.to_json)
    end
  end

  describe '#run_query' do
    before do
      allow(connection).to receive(:exec).with('SELECT 1').and_return(result)
      allow(result).to receive(:values).and_return([['1']])
    end

    it 'executes a query on the database' do
      result = adapter.run_query('SELECT 1')

      expect(connection).to have_received(:exec).with('SELECT 1')
      expect(result).to eq([['1']])
    end
  end
end
