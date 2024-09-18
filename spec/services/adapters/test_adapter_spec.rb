# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestAdapter, type: :model do
  let(:data_source) { double('DataSource') }
  let(:test_adapter) { described_class.new(data_source) }

  describe '#schemas' do
    it 'returns an empty hash' do
      expect(test_adapter.schemas).to eq({})
    end
  end

  describe '#run_query' do
    it 'responds to #run_query' do
      expect(test_adapter).to respond_to(:run_query)
    end

    # You can add more specific tests here depending on the implementation
  end

  describe '#run_raw_query' do
    it 'responds to #run_raw_query' do
      expect(test_adapter).to respond_to(:run_raw_query)
    end

    # You can add more specific tests here depending on the implementation
  end

  describe '#table_structure_query' do
    it 'returns PRAGMA SQL statement' do
      table_name = 'my_table'
      expected_query = "PRAGMA table_info(#{table_name})"
      expect(test_adapter.table_structure_query(table_name)).to eq(expected_query)
    end
  end

  describe '#count' do
    it 'returns 0' do
      query = 'SELECT * FROM my_table'
      expect(test_adapter.count(query)).to eq(0)
    end
  end

  describe '#all_records_query' do
    it 'returns a SELECT statement for the table' do
      table_name = 'my_table'
      expected_query = "SELECT * FROM #{table_name}"
      expect(test_adapter.all_records_query(table_name)).to eq(expected_query)
    end
  end
end
