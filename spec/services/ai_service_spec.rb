# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AIService do
  let(:url) { 'https://api.openai.com/v1' }
  let(:model) { 'gpt-4' }
  let(:api_key) { 'fake_api_key' }
  let(:client_response) { { 'choices' => [{ 'text' => 'Test response' }] } }

  subject(:ai_service) { described_class.new(url:, model:, api_key:) }

  let(:client) { instance_double(OpenAI::Client) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat).and_return(client_response)
  end

  describe '#initialize' do
    it 'initializes with the given URL, model, and API key' do
      expect(ai_service).to be_an_instance_of(described_class)
    end
  end

  describe '#add_message' do
    it 'adds a message to the messages array' do
      ai_service.add_message('user', 'Hello')
      expect(ai_service.messages).to eq([{ role: 'user', content: 'Hello' }])
    end
  end

  describe '#chat' do
    before do
      ai_service.add_message('user', 'Hello')
    end

    it 'sends a chat request to the OpenAI API and returns the response' do
      choices = ai_service.chat
      expect(client).to have_received(:chat).with(
        parameters: {
          model: 'gpt-4',
          response_format: { type: 'json_object' },
          messages: [{ role: 'user', content: 'Hello' }],
          temperature: 0.7
        }
      )
      expect(choices).to eq(client_response['choices'])
    end
  end
end
