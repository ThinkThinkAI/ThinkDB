# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatChannel, type: :channel do
  let(:user) { create(:user) }
  let(:stream_name) { "chat_channel_#{user.id}" }

  before do
    stub_connection current_user: user
  end

  it 'successfully subscribes to the chat channel' do
    subscribe user_id: user.id

    expect(subscription).to be_confirmed

    expect(subscription).to have_stream_from(stream_name)
  end

  it 'unsubscribes successfully' do
    subscribe user_id: user.id
    perform :unsubscribed

    expect(subscription).to be_confirmed
  end
end
