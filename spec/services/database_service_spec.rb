require 'rails_helper'

RSpec.describe DatabaseService, type: :service do
  let(:data_source) { create(:data_source) }
  let(:mock_adapter) { instance_double(PostgresAdapter) }

  before do
    allow(PostgresAdapter).to receive(:new).and_return(mock_adapter)
  end

  describe '.build' do
    it 'initializes a PostgresAdapter' do
      service = DatabaseService.build(data_source)
      expect(service).to be_an_instance_of(DatabaseService)
    end

    it 'raises an error for unsupported adapters' do
      data_source.update(adapter: 'unsupported_adapter')
      expect { DatabaseService.build(data_source) }.to raise_error('Adapter not supported: unsupported_adapter')
    end
  end

  describe '#get_schemas' do
    it 'delegates schemas to the adapter' do
      service = DatabaseService.build(data_source)
      allow(mock_adapter).to receive(:schemas).and_return('[]')
      schemas_json = service.schemas
      expect(mock_adapter).to have_received(:schemas)
      expect(schemas_json).to eq('[]')
    end
  end

  describe '#run_query' do
    it 'delegates run_query to the adapter' do
      service = DatabaseService.build(data_source)
      query = 'SELECT 1'
      allow(mock_adapter).to receive(:run_query).with(query).and_return([{ '?column?' => '1' }])
      query_result = service.run_query(query)
      expect(mock_adapter).to have_received(:run_query).with(query)
      expect(query_result).to eq([{ '?column?' => '1' }])
    end
  end
end
