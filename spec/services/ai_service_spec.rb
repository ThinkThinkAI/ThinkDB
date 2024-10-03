# frozen_string_literal: true

require 'rails_helper'

class MockOpenAIClient
  def initialize(access_token:); end

  def chat(parameters:)
    {
      'choices' => [
        {
          'message' => {
            'content' => '{"sql": "SELECT * FROM users;", "preview": "SELECT * FROM users WHERE id = 1;"}'
          }
        }
      ]
    }
  end
end

# Mocking the OpenAI::Client to use the MockOpenAIClient during tests
module OpenAI
  Client = MockOpenAIClient
end

RSpec.describe AIService do
  let(:url) { 'http://api.example.com' }
  let(:model) { 'text-davinci-003' }
  let(:api_key) { 'dummy-api-key' }
  let(:data_source) do
    double('DataSource', adapter: 'PostgreSQL', schema: 'CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);')
  end
  let(:chat_message) { double('Message', role: 'user', content: 'Show me all users.') }
  let(:chat) { double('Chat', messages: [chat_message], data_source:, qchat?: false) }
  let(:ai_service) { AIService.new(url:, model:, api_key:) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(MockOpenAIClient.new(access_token: api_key))
  end

  describe '#initialize' do
    it 'initializes with url, model and api_key' do
      expect(ai_service.instance_variable_get(:@url)).to eq(url)
      expect(ai_service.instance_variable_get(:@model)).to eq(model)
      expect(ai_service.instance_variable_get(:@api_key)).to eq(api_key)
      expect(ai_service.client).to be_an_instance_of(MockOpenAIClient)
      expect(ai_service.messages).to eq([])
    end
  end

  describe '#add_message' do
    it 'adds a message to the messages array' do
      ai_service.add_message('user', 'Hello AI')
      expect(ai_service.messages).to include({ role: 'user', content: 'Hello AI' })
    end
  end

  describe '#add_messages' do
    let(:chat) { double('Chat', messages: [chat_message, double('Message', role: 'assistant', content: 'Hi!')]) }

    it 'adds multiple messages to the messages array' do
      ai_service.add_messages(chat)
      expected_messages = [
        { role: 'user', content: 'Show me all users.' },
        { role: 'assistant', content: 'Hi!' }
      ]
      expect(ai_service.messages).to match_array(expected_messages)
    end
  end

  describe '#chat' do
    context 'when chat is qchat' do
      let(:chat) { double('Chat', qchat?: true, data_source:, messages: [chat_message]) }

      it 'sends the query_system_message to the system' do
        ai_service.chat(chat)
        expect(ai_service.messages.first[:role]).to eq('system')
        expect(ai_service.messages.first[:content]).to include('You are a smart PostgreSQL database')
      end
    end

    context 'when chat is not qchat' do
      let(:chat) { double('Chat', qchat?: false, data_source:, messages: [chat_message]) }

      it 'sends the system_message to the system' do
        ai_service.chat(chat)
        expect(ai_service.messages.first[:role]).to eq('system')
        expect(ai_service.messages.first[:content]).to include('You are a highly skilled and experienced Database Administrator')
      end
    end

    it 'sends the messages to OpenAI client and receives a valid JSON response' do
      result = ai_service.chat(chat)
      expect(result).to eq('{"sql": "SELECT * FROM users;", "preview": "SELECT * FROM users WHERE id = 1;"}')
    end
  end

  describe '#extract_json_code_block' do
    it 'extracts JSON code block from content' do
      content = 'Here is your query: ```json {"sql": "SELECT * FROM users;"}```'
      extracted = ai_service.send(:extract_json_code_block, content)
      expect(extracted).to eq('{"sql": "SELECT * FROM users;"}')
    end

    it 'returns content if no JSON code block is found' do
      content = 'Here is your result: SELECT * FROM users;'
      extracted = ai_service.send(:extract_json_code_block, content)
      expect(extracted).to eq('Here is your result: SELECT * FROM users;')
    end

    it 'returns nil if JSON parsing fails' do
      content = 'Here is your query: ```json {"sql": "SELECT * FROM users;"```'
      extracted = ai_service.send(:extract_json_code_block, content)
      expect(extracted).to be_nil
    end
  end

  describe '#system_message' do
    it 'returns the correct system message for a data source' do
      expect(ai_service.send(:system_message, data_source)).to include('PostgreSQL')
      expect(ai_service.send(:system_message, data_source)).to include(data_source.schema)
    end
  end

  describe '#query_system_message' do
    it 'returns the correct query system message for a data source' do
      expect(ai_service.send(:query_system_message, data_source)).to include('PostgreSQL')
      expect(ai_service.send(:query_system_message, data_source)).to include('You are a smart PostgreSQL database')
      expect(ai_service.send(:query_system_message, data_source)).to include(data_source.schema)
    end
  end
end
