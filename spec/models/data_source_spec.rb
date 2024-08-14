# spec/models/data_source_spec.rb

require 'rails_helper'

RSpec.describe DataSource, type: :model do
  let(:user) { create(:user) }

  # Mock the adapter interactions
  let(:database_service_mock) { instance_double("DatabaseService", build_tables: true) }

  before do
    allow(DatabaseService).to receive(:build).and_return(database_service_mock)
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:adapter) }
    it { should validate_inclusion_of(:adapter).in_array(%w[postgresql mysql sqlite]) }
    it { should validate_numericality_of(:port).only_integer.allow_nil }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:tables).dependent(:destroy) }
    it { should have_many(:queries).dependent(:destroy) }
  end

  describe 'callbacks' do
    let!(:data_source) { create(:data_source, user: user, connected: true) }

    it 'encrypts the password before saving' do
      data_source.password = 'plain_password'
      data_source.save
      expect(data_source.password).not_to eq('plain_password')
      expect(data_source.decrypt_password).to eq('plain_password')
    end

    it 'unsets other connected sources before saving if connected' do
      another_data_source = create(:data_source, user: user, connected: true)
      data_source.save
      another_data_source.reload
      expect(another_data_source.connected).to be_falsey
    end

    it 'activates the first inactive data source after destruction if none are active' do
      inactive_data_source = create(:data_source, user: user, connected: false)
      data_source.destroy
      inactive_data_source.reload
      expect(inactive_data_source.connected).to be_truthy
    end

    it 'builds tables if connected after save' do
      data_source.connected = true
      data_source.save
      expect(DatabaseService).to have_received(:build).with(data_source)
    end
  end

  describe 'scopes' do
    before do
      create(:data_source, user: user, connected: true)
      create(:data_source, user: user, connected: false)
    end

    it '.active' do
      expect(DataSource.active.count).to eq(1)
    end

    it '.inactive' do
      expect(DataSource.inactive.count).to eq(1)
    end
  end
end
