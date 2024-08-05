# frozen_string_literal: true

# spec/models/data_source_spec.rb
require 'rails_helper'

RSpec.describe DataSource, type: :model do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }

  describe 'Validations' do
    it { should validate_presence_of(:adapter) }
    it { should validate_inclusion_of(:adapter).in_array(%w[postgresql mysql sqlite]) }
    it { should validate_numericality_of(:port).only_integer }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
  end

  describe 'Callbacks' do
    context 'before save' do
      it 'encrypts the password' do
        data_source = build(:data_source, user:, password: 'plainpassword')
        expect(data_source).to receive(:encrypt_password)
        data_source.save
      end

      it 'unsets other connected sources if this one is connected' do
        data_source = create(:data_source, user:, connected: true)
        create(:data_source, user:, connected: false)

        data_source.connected = true
        expect(data_source).to receive(:unset_other_connected_sources)
        data_source.save
      end
    end

    context 'after destroy' do
      it 'activates the first available inactive data source if none active' do
        active_data_source = create(:data_source, user:, connected: true)
        inactive_data_source1 = create(:data_source, user:, connected: false)
        inactive_data_source2 = create(:data_source, user:, connected: false)

        active_data_source.destroy

        expect(inactive_data_source1.reload.connected).to be true
        expect(inactive_data_source2.reload.connected).to be false
      end

      it 'does not change state if there are still active data sources' do
        active_data_source1 = create(:data_source, user:, connected: true)
        active_data_source2 = create(:data_source, user:, connected: true)
        inactive_data_source = create(:data_source, user:, connected: false)

        active_data_source1.destroy

        expect(inactive_data_source.reload.connected).to be false
        expect(active_data_source2.reload.connected).to be true
      end
    end
  end

  describe '#encrypt_password' do
    it 'encrypts the password if present' do
      data_source.password = 'plainpassword'
      expect(data_source).to receive(:encrypt).with(data_source.password)
      data_source.save
    end
  end

  describe '#decrypt_password' do
    it 'decrypts the encrypted password' do
      plain_password = 'plainpassword'
      data_source.password = plain_password
      data_source.save
      decrypted_password = data_source.decrypt_password

      expect(decrypted_password).to eq(plain_password)
    end
  end

  describe '#unset_other_connected_sources' do
    it 'sets other connected data sources to false' do
      connected_data_source = create(:data_source, user:, connected: true)
      second_data_source = create(:data_source, user:, connected: false)

      connected_data_source.update(connected: true)
      second_data_source.reload

      expect(second_data_source.connected).to be false
    end
  end

  describe '#encryptor' do
    it 'returns an ActiveSupport::MessageEncryptor instance' do
      expect(data_source.send(:encryptor)).to be_a(ActiveSupport::MessageEncryptor)
    end
  end
end
