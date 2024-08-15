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
      allow(connection).to receive(:exec).with(
        "SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public'"
      ).and_return(pg_result)
      allow(pg_result).to receive(:each).and_yield(rows[0]).and_yield(rows[1])
    end

    it 'returns a hash with table schemas' do
      adapter = described_class.new(data_source)
      expect(adapter.schemas).to eq(
        'table1' => [
          { column_name: 'id', data_type: 'integer' },
          { column_name: 'name', data_type: 'text' }
        ]
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
      expected_query = "select * from information_schema.columns where table_name = '#{table_name}'"
      expect(adapter.table_structure_query(table_name)).to eq(expected_query)
    end
  end

  describe '#run_raw_query' do
    let(:query) { 'SELECT * FROM users' }
    let(:pg_result) { instance_double(PG::Result, values: [%w[1 Alice], %w[2 Bob]]) }

    before do
      allow(connection).to receive(:exec).with(query).and_return(pg_result)
    end

    it 'executes the raw query and returns the result values' do
      adapter = described_class.new(data_source)
      expect(adapter.run_raw_query(query)).to eq([%w[1 Alice], %w[2 Bob]])
    end
  end
end
