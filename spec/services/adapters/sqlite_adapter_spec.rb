require 'rails_helper'
require 'sqlite3'
require './app/services/adapters/sqlite_adapter'

RSpec.describe SqliteAdapter, type: :model do
  let(:data_source) do
    instance_double('DataSource', database: 'test_db.sqlite3')
  end

  let(:connection) { instance_double(SQLite3::Database) }
  let(:adapter) { SqliteAdapter.new(data_source) }

  before do
    allow(SQLite3::Database).to receive(:new).and_return(connection)
  end

  describe '#get_schemas' do
    let(:expected_result) do
      [
        %w[users id INTEGER],
        %w[users name TEXT]
      ]
    end

    before do
      allow(connection).to receive(:execute).and_return(expected_result)
    end

    it 'retrieves schemas from the database' do
      schemas = adapter.schemas

      expected_schemas = {
        'users' => [
          { column_name: 'id', data_type: 'INTEGER' },
          { column_name: 'name', data_type: 'TEXT' }
        ]
      }

      expect(schemas).to eq(expected_schemas.to_json)
    end
  end

  describe '#run_query' do
    let(:query_result) { [[1]] }

    before do
      allow(connection).to receive(:execute).with('SELECT 1').and_return(query_result)
    end

    it 'executes a query on the database' do
      result = adapter.run_query('SELECT 1')
      expect(connection).to have_received(:execute).with('SELECT 1')
      expect(result).to eq(query_result)
    end
  end
end
