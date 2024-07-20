require 'rails_helper'
require 'mysql2'
require './app/services/adapters/mysql_adapter'

RSpec.describe MysqlAdapter, type: :model do
  let(:data_source) do
    instance_double('DataSource',
                    database: 'test_db',
                    username: 'user',
                    password: 'pass',
                    host: 'localhost',
                    port: '3306')
  end

  let(:client) { instance_double(Mysql2::Client) }
  let(:adapter) { MysqlAdapter.new(data_source) }

  before do
    allow(Mysql2::Client).to receive(:new).and_return(client)
  end

  describe '#get_schemas' do
    let(:expected_rows) do
      [
        { 'table_name' => 'users', 'column_name' => 'id', 'data_type' => 'int' },
        { 'table_name' => 'users', 'column_name' => 'name', 'data_type' => 'varchar' }
      ]
    end

    before do
      allow(client).to receive(:query).and_return(expected_rows)
    end

    it 'retrieves schemas from the database' do
      schemas = adapter.get_schemas

      expected_result = {
        'users' => [
          { column_name: 'id', data_type: 'int' },
          { column_name: 'name', data_type: 'varchar' }
        ]
      }

      expect(schemas).to eq(expected_result.to_json)
    end
  end

  describe '#run_query' do
    let(:query_result) { [{ '1' => 1 }] }

    before do
      allow(client).to receive(:query).with('SELECT 1').and_return(query_result)
    end

    it 'executes a query on the database' do
      result = adapter.run_query('SELECT 1')
      expect(client).to have_received(:query).with('SELECT 1')
      expect(result).to eq(query_result)
    end
  end
end
