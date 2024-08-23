# frozen_string_literal: true

require 'rails_helper'
require 'sqlite3'
require './app/services/adapters/sqlite_adapter'

RSpec.describe SqliteAdapter, type: :service do
  let(:db_file) { ':memory:' } # In-memory database for testing
  let(:data_source) { double('DataSource', database: db_file) } # Mocking the data_source
  let(:adapter) { described_class.new(data_source) }

before do
    # Creating a test table and inserting sample data for users
    adapter.run_raw_query <<-SQL
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT
      );
    SQL

    adapter.run_raw_query <<-SQL
      INSERT INTO users (name, email)
      VALUES ('Test User 1', 'user1@example.com'),
             ('Test User 2', 'user2@example.com');
    SQL

    # Creating another table `posts` with a foreign key relationship to `users`
    adapter.run_raw_query <<-SQL
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        title TEXT,
        body TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL

    adapter.run_raw_query <<-SQL
      INSERT INTO posts (user_id, title, body)
      VALUES (1, 'First Post', 'Content of the first post'),
             (2, 'Second Post', 'Content of the second post');
    SQL
  end

  let(:table_name) { 'users' }

  describe '#table_structure_query' do
    it 'returns the correct SHOW query for fetching structure from a table' do
      expected_query = "PRAGMA table_info(#{table_name})"
      expect(adapter.table_structure_query(table_name)).to eq(expected_query)
    end
  end

  describe '#initialize' do
    it 'initializes with a database file' do
      expect(adapter.instance_variable_get(:@db_file)).to eq(db_file)
      expect(adapter.instance_variable_get(:@connection)).to be_a(SQLite3::Database)
    end
  end

  describe '#schemas' do
    it 'retrieves schema information' do
      schema = adapter.schemas
      expect(schema).to have_key('users')
      expect(schema['users']).to include(
        a_hash_including(column_name: 'id', data_type: 'INTEGER'),
        a_hash_including(column_name: 'name', data_type: 'TEXT'),
        a_hash_including(column_name: 'email', data_type: 'TEXT')
      )
    end
  end

  describe '#run_query' do
    it 'executes a query with limit and offset' do
      result = adapter.run_query('SELECT * FROM users', 1, 1)
      expect(result).to eq([
                             ['id', 'name', 'email'],
                             [2, 'Test User 2', 'user2@example.com']
                           ])
    end

    it 'executes a query with sorting' do
      allow(adapter).to receive(:add_sorting).and_call_original
      result = adapter.run_query('SELECT * FROM users', 10, 0, { column: 'name', order: 'desc' })
      expect(result).to eq([
                             ['id', 'name', 'email'],
                             [2, 'Test User 2', 'user2@example.com'],
                             [1, 'Test User 1', 'user1@example.com']
                           ])
    end
  end

  describe '#run_raw_query' do
    it 'executes a raw query' do
      result = adapter.run_raw_query('SELECT name FROM users')
      expect(result).to contain_exactly(
        ['Test User 1'],
        ['Test User 2']
      )
    end
  end

  describe '#add_sorting' do
    it 'adds sorting to a query' do
      sorted_query = adapter.send(:add_sorting, 'SELECT * FROM users', { column: 'name', order: 'desc' })
      expect(sorted_query).to end_with('ORDER BY name DESC')
    end
  end

  describe '#add_offset' do
    it 'adds offset and limit to a query' do
      offset_query = adapter.send(:add_offset, 'SELECT * FROM users', 10, 20)
      expect(offset_query).to end_with('LIMIT 10 OFFSET 20')
    end
  end

  describe '#count' do
    it 'counts the records for a given query' do
      allow(adapter).to receive(:supported_query_type?).and_return(true)
      allow(adapter).to receive(:convert_to_count_query).and_return('SELECT COUNT(*) AS count FROM users')
      result = adapter.count('SELECT * FROM users')
      expect(result).to eq(2)
    end
  end
end
