# spec/services/database_service_spec.rb
require 'rails_helper'
require 'json'
# require_relative '../../app/services/database_service'

RSpec.describe DatabaseService do
  let(:data_source) do
    instance_double('DataSource',
                    adapter: 'postgresql',
                    update: nil,
                    tables: instance_double('Tables', destroy_all: nil, create: nil))
  end
  let(:adapter) { instance_double('Adapter') }
  let(:database_service) { described_class.new(adapter, data_source) }

  before do
    allow(PostgresqlAdapter).to receive(:new).with(data_source).and_return(adapter)
    allow(MysqlAdapter).to receive(:new).with(data_source).and_return(adapter)
    allow(SqliteAdapter).to receive(:new).with(data_source).and_return(adapter)
  end

  describe '.build' do
    it 'raises an error for unsupported adapters' do
      allow(data_source).to receive(:adapter).and_return('unsupported')
      expect { described_class.build(data_source) }.to raise_error("Adapter not supported: unsupported")
    end

    it 'returns a new DatabaseService instance for supported adapters' do
      allow(data_source).to receive(:adapter).and_return('postgresql')
      service = described_class.build(data_source)
      expect(service).to be_an_instance_of(DatabaseService)
    end
  end

  describe '#initialize' do
    it 'sets the adapter and data_source' do
      expect(database_service.instance_variable_get(:@adapter)).to eq(adapter)
      expect(database_service.instance_variable_get(:@data_source)).to eq(data_source)
    end
  end

  describe '#build_tables' do
    let(:schemas) { { 'users' => [{ column_name: 'id', data_type: 'integer' }] } }

    before do
      allow(adapter).to receive(:schemas).and_return(schemas)
    end

    it 'updates the data_source schema and creates tables' do
      expect(data_source).to receive(:update).with(schema: schemas.to_json)
      expect(data_source.tables).to receive(:destroy_all)
      expect(data_source.tables).to receive(:create).with(name: 'users')

      database_service.build_tables
    end
  end

  describe '#format_json' do
    it 'formats the data into JSON structure' do
      data = [%w[id name], [1, 'Alice'], [2, 'Bob']]
      expected_result = [{ 'id' => 1, 'name' => 'Alice' }, { 'id' => 2, 'name' => 'Bob' }]
      expect(database_service.format_json(data)).to eq(expected_result)
    end

    it "returns an empty array if there's no data" do
      expect(database_service.format_json([])).to be_empty
    end
  end

  describe '#run_query' do
    let(:query) { 'SELECT * FROM users' }
    let(:raw_data) { [%w[id name], ['1', 'Alice'], ['2', 'Bob']] }

    before do
      allow(adapter).to receive(:run_query).and_return(raw_data)
    end

    it 'returns the raw data by default' do
      expect(database_service.run_query(query)).to eq(raw_data)
    end

    it 'formats the data as JSON if requested' do
      expected_result = [
        { 'id' => '1', 'name' => 'Alice' },
        { 'id' => '2', 'name' => 'Bob' }
      ]
      expect(database_service.run_query(query, format: 'json')).to eq(expected_result)
    end
  end

  describe '#run_raw_query' do
    let(:query) { 'SELECT * FROM users' }
    let(:result) { [['1', 'Alice'], ['2', 'Bob']] }

    before do
      allow(adapter).to receive(:run_raw_query).with(query).and_return(result)
    end

    it 'executes the raw query and returns the result' do
      expect(database_service.run_raw_query(query)).to eq(result)
    end
  end

  describe '#column_names' do
    let(:query) { 'SELECT * FROM users' }
    let(:first_row) { %w[id name] }

    before do
      allow(adapter).to receive(:run_query).and_return([first_row])
    end

    it 'returns the column names of the first row' do
      expect(database_service.column_names(query)).to eq(first_row)
    end
  end

  describe '#count' do
    let(:query) { 'SELECT COUNT(*) FROM users' }
    let(:count_result) { 2 }

    before do
      allow(adapter).to receive(:count).with(query).and_return(count_result)
    end

    it 'returns the row count for the query' do
      expect(database_service.count(query)).to eq(count_result)
    end
  end
end
