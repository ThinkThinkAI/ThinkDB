# frozen_string_literal: true

require 'rails_helper'
require 'pg'
require './app/services/adapters/postgresql_adapter'

RSpec.describe PostgresqlAdapter do
  let(:data_source) do
    OpenStruct.new(
      database: 'test_db',
      username: 'test_user',
      password: 'test_pass',
      decrypt_password: 'test_pass',
      host: 'localhost',
      port: 5432
    )
  end
  let(:connection) { instance_double(PG::Connection) }

  before do
    allow(PG).to receive(:connect).and_return(connection)
  end

  describe '#initialize' do
    it 'creates a new PG connection with the provided parameters' do
      described_class.new(data_source)
      expect(PG).to have_received(:connect).with(
        dbname: data_source.database,
        user: data_source.username,
        password: data_source.password,
        host: data_source.host,
        port: data_source.port
      )
    end
  end

  describe '#schemas' do
    let(:pg_result) { instance_double(PG::Result) }
    let(:rows) do
      [
        { 'table_name' => 'table1', 'column_name' => 'id', 'data_type' => 'integer' },
        { 'table_name' => 'table1', 'column_name' => 'name', 'data_type' => 'text' }
      ]
    end

    before do
      schema_query = <<-SQL
    SELECT
      c.table_name,
      c.column_name,
      c.data_type,
      kcu.constraint_name,
      kcu.ordinal_position,
      kcu.position_in_unique_constraint,
      tc.constraint_type,
      ct.referenced_table_name,
      ct.referenced_column_name
    FROM information_schema.columns c
    LEFT JOIN information_schema.key_column_usage kcu
      ON c.table_name = kcu.table_name
      AND c.column_name = kcu.column_name
      AND c.table_schema = kcu.table_schema
    LEFT JOIN information_schema.table_constraints tc
      ON kcu.constraint_name = tc.constraint_name
      AND kcu.table_schema = tc.table_schema
    LEFT JOIN (
      SELECT
        r.conname AS constraint_name,
        ccu.table_name AS table_name,
        r.confrelid::regclass::text AS referenced_table_name,
        a.attname AS referenced_column_name,
        ccu.table_schema
      FROM pg_constraint r
      JOIN information_schema.constraint_column_usage ccu
        ON r.conname = ccu.constraint_name
        AND r.connamespace::regnamespace::text = ccu.constraint_schema
      JOIN pg_attribute a
        ON a.attnum = ANY (r.confkey)
        AND a.attrelid = r.confrelid
      WHERE r.contype = 'f'
    ) ct
      ON kcu.constraint_name = ct.constraint_name
      AND kcu.table_schema = ct.table_schema
      AND kcu.table_name = ct.table_name
    WHERE c.table_schema = 'public'
      SQL
      allow(connection).to receive(:exec).with(
        schema_query
      ).and_return(pg_result)
      allow(pg_result).to receive(:each).and_yield(rows[0]).and_yield(rows[1])
    end

    it 'returns a hash with table schemas' do
      adapter = described_class.new(data_source)
      schemas = adapter.schemas

      simplified_schema = schemas['table1'].map do |column|
        column.slice(:column_name, :data_type)
      end

      expect(simplified_schema).to include(
        { column_name: 'id', data_type: 'integer' },
        { column_name: 'name', data_type: 'text' }
      )
    end
  end

  describe '#run_query' do
    let(:query) { 'SELECT * FROM users' }
    let(:pg_result) do
      instance_double(PG::Result, fields: %w[id name], values: [%w[1 Alice], %w[2 Bob]])
    end

    before do
      allow(connection).to receive(:exec).and_return(pg_result)
    end

    it 'executes the query and returns the result with fields and values' do
      adapter = described_class.new(data_source)
      result = adapter.run_query(query)
      expect(result).to eq([%w[id name], %w[1 Alice], %w[2 Bob]])
    end
  end

  let(:table_name) { 'users' }

  describe '#table_structure_query' do
    it 'returns the correct SHOW query for fetching structure from a table' do
      adapter = described_class.new(data_source)
      expected_query = "select column_name, is_nullable, data_type, column_default, character_maximum_length, numeric_precision, numeric_scale, datetime_precision, udt_name, column_default, is_identity, identity_generation, identity_start, identity_increment, identity_maximum, identity_minimum, identity_cycle from information_schema.columns where table_name = '#{table_name}'"
      expect(adapter.table_structure_query(table_name)).to eq(expected_query)
    end
  end

  describe '#run_raw_query' do
    let(:select_query) { 'SELECT * FROM users' }
    let(:pg_select_result) { instance_double(PG::Result, values: [%w[1 Alice], %w[2 Bob]]) }

    before do
      allow(connection).to receive(:exec).with(select_query).and_return(pg_select_result)
    end

    it 'executes the raw SELECT query and returns the result values' do
      adapter = described_class.new(data_source)
      expect(adapter.run_raw_query(select_query)).to eq([%w[1 Alice], %w[2 Bob]])
    end

    context 'when executing INSERT query' do
      let(:insert_query) { "INSERT INTO users (name) VALUES ('Eve')" }
      let(:pg_insert_result) { instance_double(PG::Result, cmd_tuples: 1) }

      before do
        allow(connection).to receive(:exec).with(insert_query).and_return(pg_insert_result)
      end

      it 'returns the number of affected rows' do
        adapter = described_class.new(data_source)
        expect(adapter.run_raw_query(insert_query)).to eq(1)
      end
    end

    context 'when executing UPDATE query' do
      let(:update_query) { "UPDATE users SET name = 'Eve' WHERE id = 1" }
      let(:pg_update_result) { instance_double(PG::Result, cmd_tuples: 1) }

      before do
        allow(connection).to receive(:exec).with(update_query).and_return(pg_update_result)
      end

      it 'returns the number of affected rows' do
        adapter = described_class.new(data_source)
        expect(adapter.run_raw_query(update_query)).to eq(1)
      end
    end

    context 'when executing DELETE query' do
      let(:delete_query) { 'DELETE FROM users WHERE id = 1' }
      let(:pg_delete_result) { instance_double(PG::Result, cmd_tuples: 1) }

      before do
        allow(connection).to receive(:exec).with(delete_query).and_return(pg_delete_result)
      end

      it 'returns the number of affected rows' do
        adapter = described_class.new(data_source)
        expect(adapter.run_raw_query(delete_query)).to eq(1)
      end
    end

    context 'when executing DROP query' do
      let(:drop_query) { 'DROP TABLE users' }
      let(:pg_drop_result) { instance_double(PG::Result, cmd_tuples: 0) }

      before do
        allow(connection).to receive(:exec).with(drop_query).and_return(pg_drop_result)
      end

      it 'returns the number of affected rows' do
        adapter = described_class.new(data_source)
        expect(adapter.run_raw_query(drop_query)).to eq(0)
      end
    end

    context 'when executing CREATE query' do
      let(:create_query) { 'CREATE TABLE new_table (id INT, name TEXT)' }
      let(:pg_create_result) { instance_double(PG::Result, cmd_tuples: 0) }

      before do
        allow(connection).to receive(:exec).with(create_query).and_return(pg_create_result)
      end

      it 'returns the number of affected rows' do
        adapter = described_class.new(data_source)
        expect(adapter.run_raw_query(create_query)).to eq(0)
      end
    end

    context 'when executing ALTER query' do
      let(:alter_query) { 'ALTER TABLE users ADD COLUMN age INT' }
      let(:pg_alter_result) { instance_double(PG::Result, cmd_tuples: 0) }

      before do
        allow(connection).to receive(:exec).with(alter_query).and_return(pg_alter_result)
      end

      it 'returns the number of affected rows' do
        adapter = described_class.new(data_source)
        expect(adapter.run_raw_query(alter_query)).to eq(0)
      end
    end
  end
end
