# frozen_string_literal: true

require 'rails_helper'
require 'mysql2'
require './app/services/adapters/mysql_adapter'

RSpec.describe MysqlAdapter, type: :service do
  let(:data_source) do
    double('DataSource',
           database: 'test_db',
           username: 'test_user',
           password: 'test_password',
           decrypt_password: 'test_password',
           host: 'localhost',
           port: 3306)
  end

  let(:mock_client) { instance_double(Mysql2::Client) }
  let(:adapter) { described_class.new(data_source) }

  let(:table_name) { 'users' }

  describe '#table_structure_query' do
    it 'returns the correct SELECT query for fetching all records from a table' do
      expected_query = "SHOW COLUMNS FROM #{table_name}"
      expect(adapter.table_structure_query(table_name)).to eq(expected_query)
    end
  end

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
      schema_query = <<-SQL
      SELECT DISTINCT c.table_name, c.column_name, c.data_type,
             k.constraint_name, k.ordinal_position, k.position_in_unique_constraint, k.referenced_table_name, k.referenced_column_name,
             t.constraint_type
      FROM information_schema.columns c
      LEFT JOIN information_schema.key_column_usage k
      ON c.table_schema = k.table_schema
      AND c.table_name = k.table_name
      AND c.column_name = k.column_name
      LEFT JOIN information_schema.table_constraints t
      ON k.constraint_name = t.constraint_name
      WHERE c.table_schema = 'test_db'
      SQL

      schema_result = [
        { 'table_name' => 'users', 'column_name' => 'id', 'data_type' => 'INT' },
        { 'table_name' => 'users', 'column_name' => 'name', 'data_type' => 'VARCHAR' }
      ]

      allow(mock_client).to receive(:query).with(schema_query).and_return(schema_result)

      schema = adapter.schemas
      expect(schema).to have_key('users')
      expect(schema['users']).to include(
        a_hash_including(column_name: 'id', data_type: 'INT'),
        a_hash_including(column_name: 'name', data_type: 'VARCHAR')
      )
    end
  end

  describe '#run_query' do
    it 'executes a query with limit and offset' do
      query = 'SELECT * FROM users'
      mock_result = [
        { 'id' => 2, 'name' => 'Test User 2', 'email' => 'user2@example.com' }
      ]

      allow(mock_client).to receive(:query).with('(SELECT * FROM users)').and_return(mock_result)

      result = adapter.run_query(query, 1, 1)
      expect(result).to eq([['id', 'name', 'email'], [2, 'Test User 2', 'user2@example.com']])
    end

    it 'executes a query with sorting' do
      query = 'SELECT * FROM users'
      mock_result = [
        { 'id' => 2, 'name' => 'Test User 2', 'email' => 'user2@example.com' },
        { 'id' => 1, 'name' => 'Test User 1', 'email' => 'user1@example.com' }
      ]

      allow(mock_client).to receive(:query).with('(SELECT * FROM users)').and_return(mock_result)

      result = adapter.run_query(query, 10, 0, { column: 'name', order: 'desc' })
      expect(result).to eq([['id', 'name', 'email'], [2, 'Test User 2', 'user2@example.com'],
                            [1, 'Test User 1', 'user1@example.com']])
    end
  end

  # Add the following to `spec/services/adapters/mysql_adapter_spec.rb`

  describe '#run_raw_query' do
    it 'executes a raw SELECT query' do
      query = 'SELECT name FROM users'
      mock_result = [
        { 'name' => 'Test User 1' },
        { 'name' => 'Test User 2' }
      ]

      allow(mock_client).to receive(:query).with(query).and_return(mock_result)

      result = adapter.run_raw_query(query)
      expect(result).to eq([['Test User 1'], ['Test User 2']])
    end

    it 'executes a raw INSERT query' do
      query = "INSERT INTO users (name, email) VALUES ('New User', 'newuser@example.com')"
      affected_rows = 1

      allow(mock_client).to receive(:query).with(query).and_return(double(affected_rows:))

      result = adapter.run_raw_query(query)
      expect(result).to eq(affected_rows)
    end

    it 'executes a raw UPDATE query' do
      query = "UPDATE users SET email='updated@example.com' WHERE name='Old User'"
      affected_rows = 1

      allow(mock_client).to receive(:query).with(query).and_return(double(affected_rows:))

      result = adapter.run_raw_query(query)
      expect(result).to eq(affected_rows)
    end

    it 'executes a raw DELETE query' do
      query = "DELETE FROM users WHERE name='Test User'"
      affected_rows = 1

      allow(mock_client).to receive(:query).with(query).and_return(double(affected_rows:))

      result = adapter.run_raw_query(query)
      expect(result).to eq(affected_rows)
    end

    it 'executes a raw DROP query' do
      query = 'DROP TABLE users'
      affected_rows = 0

      allow(mock_client).to receive(:query).with(query).and_return(double(affected_rows:))

      result = adapter.run_raw_query(query)
      expect(result).to eq(affected_rows)
    end

    it 'executes a raw CREATE query' do
      query = 'CREATE TABLE new_table (id INT, name VARCHAR(255))'
      affected_rows = 0

      allow(mock_client).to receive(:query).with(query).and_return(double(affected_rows:))

      result = adapter.run_raw_query(query)
      expect(result).to eq(affected_rows)
    end

    it 'executes a raw ALTER query' do
      query = 'ALTER TABLE users ADD COLUMN age INT'
      affected_rows = 0

      allow(mock_client).to receive(:query).with(query).and_return(double(affected_rows:))

      result = adapter.run_raw_query(query)
      expect(result).to eq(affected_rows)
    end
  end
end
