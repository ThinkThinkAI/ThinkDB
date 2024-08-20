require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe AIResponseJob, type: :job do
  let(:user) { create(:user, ai_url: 'http://ai.example.com', ai_model: 'text-davinci-003', ai_api_key: 'test_api_key') }
  let(:data_source) { create(:data_source, user: user) }
  let(:chat) { create(:chat, data_source: data_source) }
  let(:messages_partial) { 'messages/message' }

  before do
    allow_any_instance_of(AIService).to receive(:chat).and_return('AI Response')
    allow(ActionCable.server).to receive(:broadcast)
  end

  it 'creates a new message with content from AI service' do
    expect { AIResponseJob.new.perform(chat.id) }.to change { chat.messages.count }.by(1)
    expect(chat.messages.last.content).to eq('AI Response')
    expect(chat.messages.last.role).to eq('assistant')
  end

  it 'correctly broadcasts the AI response' do
    AIResponseJob.new.perform(chat.id)
    message = chat.messages.last
    message_sql = message.preview || message.sql
    message_id = "id#{message.id}"
    rendered_message = ApplicationController.render(partial: messages_partial, locals: { message: message })
    expected_payload = { ai_response: rendered_message, message_id: message_id, message_sql: message_sql }

    expect(ActionCable.server).to have_received(:broadcast).with("chat_channel_#{user.id}", expected_payload)
  end
end
