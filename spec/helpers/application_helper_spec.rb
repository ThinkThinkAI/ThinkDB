# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#text_muted' do
    context 'when user is not connected' do
      it 'returns "text-muted"' do
        allow(helper).to receive(:connected?).and_return(false)
        expect(helper.text_muted).to eq('text-muted')
      end
    end

    context 'when user is connected' do
      it 'returns nil' do
        allow(helper).to receive(:connected?).and_return(true)
        expect(helper.text_muted).to be_nil
      end
    end
  end

  describe '#connected?' do
    context 'when user is signed in and has a connected data source' do
      let(:user) { instance_double('User', connected_data_source: 'some_data_source') }

      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).and_return(user)
      end

      it 'returns true' do
        expect(helper.connected?).to be true
      end
    end

    context 'when user is signed in but does not have a connected data source' do
      let(:user) { instance_double('User', connected_data_source: nil) }

      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).and_return(user)
      end

      it 'returns false' do
        expect(helper.connected?).to be false
      end
    end

    context 'when user is not signed in' do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'returns false' do
        expect(helper.connected?).to be false
      end
    end
  end
end
