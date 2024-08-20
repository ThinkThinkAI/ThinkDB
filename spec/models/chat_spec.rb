require 'rails_helper'

RSpec.describe Chat, type: :model do
  let(:data_source) { create(:data_source) }

  subject {
    described_class.new(name: 'Sample Chat', data_source: data_source)
  }

  describe 'associations' do
    it { should belong_to(:data_source) }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
