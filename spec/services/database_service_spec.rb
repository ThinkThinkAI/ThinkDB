require 'rails_helper'
require './app/services/database_service'
require './app/services/adapters/postgres_adapter'

RSpec.describe DatabaseService, type: :model do
  let(:data_source) { instance_double('DataSource', adapter: 'postgresql', database: 'test_db') }
  let(:adapter) { instance_double(PostgresAdapter) }
  let(:service) { DatabaseService.new(adapter) }

  before do
    allow(PostgresAdapter).to receive(:new).and_return(adapter)
  end

  describe '.build' do
    it 'builds the appropriate adapter based on the data source' do
      database_service = DatabaseService.build(data_source)
      expect(database_service).to be_a(DatabaseService)
    end
  end

  describe '#schemas' do
    let(:schemas) { { 'users' => [{ column_name: 'id', data_type: 'integer' }] }.to_json }

    it 'delegates the schemas method to the adapter' do
      allow(adapter).to receive(:schemas).and_return(schemas)
      result = service.schemas
      expect(result).to eq(schemas)
    end
  end

  describe '#run_raw_query' do
    let(:query) { 'SELECT 1' }
    let(:query_result) { [{ 'id' => 1 }] }

    it 'executes a raw query via the adapter' do
      allow(adapter).to receive(:run_raw_query).with(query).and_return(query_result)
      result = service.run_raw_query(query)
      expect(result).to eq(query_result)
    end
  end

  describe '#count' do
    context 'with supported queries' do
      let!(:select_query) { 'SELECT * FROM users' }
      let!(:update_query) { 'UPDATE users SET name = "New Name" WHERE age > 30' }
      let!(:delete_query) { 'DELETE FROM users WHERE age > 30' }
      let!(:insert_query) { 'INSERT INTO users (name, age) VALUES ("Alice", 25), ("Bob", 30)' }
      let!(:insert_select_query) { 'INSERT INTO users (name, age) SELECT name, age FROM old_users WHERE age > 20' }

      it 'returns the correct count for SELECT queries' do
        allow(service).to receive(:run_raw_query).with('SELECT COUNT(*) AS count FROM (SELECT * FROM users) AS subquery')
                                                 .and_return([{ 'count' => 100 }])
        expect(service.count(select_query)).to eq(100)
      end

      it 'returns the correct count for UPDATE queries' do
        allow(service).to receive(:run_raw_query).with('SELECT COUNT(*) AS count FROM users WHERE age > 30')
                                                 .and_return([{ 'count' => 50 }])
        expect(service.count(update_query)).to eq(50)
      end

      it 'returns the correct count for DELETE queries' do
        allow(service).to receive(:run_raw_query).with('SELECT COUNT(*) AS count FROM users WHERE age > 30')
                                                 .and_return([{ 'count' => 50 }])
        expect(service.count(delete_query)).to eq(50)
      end

      it 'returns the correct count for INSERT queries with VALUES' do
        allow(service).to receive(:run_raw_query).with('SELECT 2 AS count')
                                                 .and_return([{ 'count' => 2 }])
        expect(service.count(insert_query)).to eq(2)
      end

      it 'returns the correct count for INSERT queries with SELECT' do
        allow(service).to receive(:run_raw_query).with('SELECT COUNT(*) AS count FROM (SELECT name, age FROM old_users WHERE age > 20) AS subquery')
                                                 .and_return([{ 'count' => 5 }])
        expect(service.count(insert_select_query)).to eq(5)
      end
    end

    context 'with unsupported queries' do
      let(:unsupported_query) { 'DROP TABLE users' }

      it 'returns nil for unsupported queries' do
        expect(service.count(unsupported_query)).to be_nil
      end
    end
  end
end
