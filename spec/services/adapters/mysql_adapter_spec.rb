require 'rails_helper'
require 'mysql2'
require './app/services/adapters/mysql_adapter'


RSpec.describe MysqlAdapter, type: :service do
  let(:data_source) do
    double('DataSource',
           database: 'test_db',
           username: 'test_user',
           password: 'test_password',
           host: 'localhost',
           port: 3306)
  end

  let(:mock_client) { instance_double(Mysql2::Client) }
  let(:adapter) { described_class.new(data_source) }

  before do
    allow(Mysql2::Client).to receive(:new).with(
      hash_including(
        database: 'test_db',
        username: 'test_user',
        password: 'test_password',
        host: 'localhost',
        port: 3306
      )
    ).and_return(mock_client)
  end

  describe '#initialize' do
    it 'initializes with connection parameters' do
      expect(adapter.instance_variable_get(:@client)).to eq(mock_client)
      expect(adapter.instance_variable_get(:@data_source)).to eq(data_source)
    end
  end

  describe '#schemas' do
    it 'retrieves schema information' do
      schema_query = "SELECT table_name, column_name, data_type FROM information_schema.columns where table_schema='test_user'"
      schema_result = [
        { 'table_name' => 'users', 'column_name' => 'id', 'data_type' => 'INT' },
        { 'table_name' => 'users', 'column_name' => 'name', 'data_type' => 'VARCHAR' }
      ]

      allow(mock_client).to receive(:query).with(schema_query).and_return(schema_result)

      schema = adapter.schemas
      expect(schema).to have_key('users')
      expect(schema['users']).to include(
        { column_name: 'id', data_type: 'INT' },
        { column_name: 'name', data_type: 'VARCHAR' }
      )
    end
  end

  describe '#run_query' do
    it 'executes a query with limit and offset' do
      query = 'SELECT * FROM users'
      limited_query = "#{query} LIMIT 1 OFFSET 1"
      mock_result = [
        { 'id' => 2, 'name' => 'Test User 2', 'email' => 'user2@example.com' }
      ]

      allow(mock_client).to receive(:query).with(limited_query).and_return(mock_result)

      result = adapter.run_query(query, 1, 1)
      expect(result).to eq([['id', 'name', 'email'], [2, 'Test User 2', 'user2@example.com']])
    end

    it 'executes a query with sorting' do
      query = 'SELECT * FROM users'
      sorted_query = "#{query} ORDER BY name DESC LIMIT 10 OFFSET 0"
      mock_result = [
        { 'id' => 2, 'name' => 'Test User 2', 'email' => 'user2@example.com' },
        { 'id' => 1, 'name' => 'Test User 1', 'email' => 'user1@example.com' }
      ]

      allow(mock_client).to receive(:query).with(sorted_query).and_return(mock_result)

      result = adapter.run_query(query, 10, 0, { column: 'name', order: 'desc' })
      expect(result).to eq([['id', 'name', 'email'], [2, 'Test User 2', 'user2@example.com'], [1, 'Test User 1', 'user1@example.com']])
    end
  end

  describe '#run_raw_query' do
    it 'executes a raw query' do
      query = 'SELECT name FROM users'
      mock_result = [
        { 'name' => 'Test User 1' },
        { 'name' => 'Test User 2' }
      ]

      allow(mock_client).to receive(:query).with(query).and_return(mock_result)

      result = adapter.run_raw_query(query)
      expect(result).to eq([['Test User 1'], ['Test User 2']])
    end
  end
end
