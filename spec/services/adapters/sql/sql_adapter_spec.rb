# frozen_string_literal: true

require 'rails_helper'
require './app/services/adapters/sql/sql_adapter'

RSpec.describe SQLAdapter do
  let(:adapter) { SQLAdapter.new }
  let(:table_name) { 'users' }

  describe '#all_records_query' do
    it 'returns the correct SELECT query for fetching all records from a table' do
      expected_query = "SELECT * FROM #{table_name}"
      expect(adapter.all_records_query(table_name)).to eq(expected_query)
    end

    it 'handles table names with special characters correctly' do
      table_name_with_special_chars = 'user-data'
      expected_query = 'SELECT * FROM user-data'
      expect(adapter.all_records_query(table_name_with_special_chars)).to eq(expected_query)
    end
  end

  describe '#run_raw_query' do
    it 'raises NotImplementedError' do
      expect do
        adapter.run_raw_query('SELECT * FROM users')
      end.to raise_error(NotImplementedError,
                         'Subclasses must implement the run_raw_query method')
    end
  end

  describe '#count' do
    before do
      allow_any_instance_of(SQLAdapter).to receive(:run_raw_query)
        .and_return([[5]])
    end

    context 'when dealing with different query types' do
      it 'returns count for a valid SELECT query' do
        query = 'SELECT * FROM users'
        expect(adapter.count(query)).to eq(5)
      end

      it 'returns count for a valid UPDATE query' do
        query = 'UPDATE users SET name = "John" WHERE active = 1'
        expect(adapter.count(query)).to eq(5)
      end

      it 'returns count for a valid DELETE query' do
        query = 'DELETE FROM users WHERE active = 1'
        expect(adapter.count(query)).to eq(5)
      end

      it 'returns count for a valid INSERT query with SELECT' do
        query = 'INSERT INTO users (name, email) SELECT name, email FROM new_users'
        expect(adapter.count(query)).to eq(5)
      end

      it 'returns count for a valid INSERT query with VALUES' do
        query = 'INSERT INTO users (name, email) VALUES ("Alice", "alice@example.com"), ("Bob", "bob@example.com")'
        allow_any_instance_of(SQLAdapter).to receive(:run_raw_query)
          .and_return([[2]])
        expect(adapter.count(query)).to eq(2)
      end
    end
  end

  describe '#add_sorting' do
    it 'removes existing ORDER BY clause and adds the new one' do
      query = 'SELECT * FROM users ORDER BY age ASC'
      sort = { column: 'name', order: 'desc' }
      result = 'SELECT * FROM users ORDER BY name DESC'
      expect(adapter.send(:add_sorting, query, sort).sub('  ', ' ')).to eq(result)
    end

    it 'adds a new ORDER BY clause if one does not exist' do
      query = 'SELECT * FROM users'
      sort = { column: 'name', order: 'desc' }
      result = 'SELECT * FROM users ORDER BY name DESC'
      expect(adapter.send(:add_sorting, query, sort)).to eq(result)
    end

    it 'replaces existing ORDER BY clause' do
      query = 'SELECT * FROM users ORDER BY id ASC'
      sort = { column: 'name', order: 'desc' }
      result = 'SELECT * FROM users ORDER BY name DESC'
      expect(adapter.send(:add_sorting, query, sort).sub('  ', ' ')).to eq(result)
    end

    it 'handles complex queries' do
      query = 'SELECT name, COUNT(*) FROM users GROUP BY name ORDER BY name ASC'
      sort = { column: 'email', order: 'desc' }
      result = 'SELECT name, COUNT(*) FROM users GROUP BY name ORDER BY email DESC'
      expect(adapter.send(:add_sorting, query, sort).sub('  ', ' ')).to eq(result)
    end
  end

  describe '#add_offset' do
    it 'adds LIMIT and OFFSET to a SELECT query' do
      query = 'SELECT * FROM users'
      limit = 10
      offset = 5
      result = 'SELECT * FROM users LIMIT 10 OFFSET 5'
      expect(adapter.send(:add_offset, query, limit, offset)).to eq(result)
    end

    it 'does not add LIMIT and OFFSET to a non-SELECT query' do
      query = 'UPDATE users SET name = "John" WHERE id = 1'
      limit = 10
      offset = 5
      expect(adapter.send(:add_offset, query, limit, offset)).to eq(query)
    end
  end

  describe '#supported_query_type?' do
    it 'returns true for supported query types' do
      expect(adapter.send(:supported_query_type?, 'SELECT * FROM users')).to be true
      expect(adapter.send(:supported_query_type?, 'UPDATE users SET name = "John"')).to be true
      expect(adapter.send(:supported_query_type?, 'DELETE FROM users WHERE id = 1')).to be true
      expect(adapter.send(:supported_query_type?, 'INSERT INTO users (name) VALUES ("John")')).to be true
    end

    it 'returns false for unsupported query types' do
      expect(adapter.send(:supported_query_type?, 'CREATE TABLE users (id int)')).to be false
      expect(adapter.send(:supported_query_type?, 'DROP TABLE users')).to be false
      expect(adapter.send(:supported_query_type?, 'ALTER TABLE users ADD COLUMN age int')).to be false
    end
  end

  describe '#convert_to_count_query' do
    it 'converts SELECT queries to COUNT queries' do
      query = 'SELECT * FROM users'
      count_query = 'SELECT COUNT(*) AS count FROM (SELECT * FROM users) AS subquery'
      expect(adapter.send(:convert_to_count_query, query)).to eq(count_query)
    end

    it 'converts UPDATE queries to COUNT queries' do
      query = 'UPDATE users SET name = "John" WHERE active = 1'
      count_query = 'SELECT COUNT(*) AS count FROM users WHERE active = 1'
      expect(adapter.send(:convert_to_count_query, query)).to eq(count_query)
    end

    it 'converts DELETE queries to COUNT queries' do
      query = 'DELETE FROM users WHERE active = 1'
      count_query = 'SELECT COUNT(*) AS count FROM users WHERE active = 1'
      expect(adapter.send(:convert_to_count_query, query)).to eq(count_query)
    end

    it 'converts INSERT...SELECT queries to COUNT queries' do
      query = 'INSERT INTO users (name, email) SELECT name, email FROM new_users'
      select_query = query.sub(/insert\s+into.*select/i, 'SELECT')
      count_query = "SELECT COUNT(*) AS count FROM (#{select_query}) AS subquery"
      expect(adapter.send(:convert_to_count_query, query)).to eq(count_query)
    end

    it 'converts INSERT...VALUES queries to COUNT queries' do
      query = 'INSERT INTO users (name, email) VALUES ("Alice", "alice@example.com"), ("Bob", "bob@example.com")'
      count_query = 'SELECT 2 AS count'
      expect(adapter.send(:convert_to_count_query, query)).to eq(count_query)
    end
  end
end
