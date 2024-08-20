require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:chat) { create(:chat) }
  let(:message) { create(:message, chat: chat) }

  describe 'associations' do
    it { should belong_to(:chat) }
  end

  describe 'validations' do
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:content) }
  end

  describe 'callbacks' do
    context 'after_create :update_chat_name' do
      it 'updates chat name if role is user' do
        message = create(:message, chat: chat, role: 'user', content: 'Hello World')
        expect(chat.name).to eq('Hello World')
      end

      it 'does not update chat name if role is not user' do
        message = create(:message, chat: chat, role: 'system', content: 'System Message')
        expect(chat.name).not_to eq('System Message')
      end
    end
  end

  describe '#sql' do
    it 'parses the SQL from the content' do
      message = create(:message, chat: chat, content: '{"sql": "SELECT * FROM users"}')
      expect(message.sql).to eq('SELECT * FROM users')
    end

    it 'returns nil if content is not valid JSON' do
      message = create(:message, chat: chat, content: 'invalid json')
      expect(message.sql).to be_nil
    end
  end

  describe '#preview' do
    it 'parses the preview from the content' do
      message = create(:message, chat: chat, content: '{"preview": "Preview content"}')
      expect(message.preview).to eq('Preview content')
    end

    it 'returns nil if content is not valid JSON' do
      message = create(:message, chat: chat, content: 'invalid json')
      expect(message.preview).to be_nil
    end
  end

  describe '#sql' do
    it 'parses the SQL from the content' do
      message = create(:message, chat: chat, content: '{"sql": "SELECT * FROM users"}')
      expect(message.sql).to eq('SELECT * FROM users')
    end

    it 'returns nil if content is not valid JSON' do
      message = create(:message, chat: chat, content: 'invalid json')
      expect(message.sql).to be_nil
    end

    it 'returns nil if sql key is not present in the content' do
      message = create(:message, chat: chat, content: '{"preview": "Preview content"}')
      expect(message.sql).to be_nil
    end
  end

  describe '#preview' do
    it 'parses the preview from the content' do
      message = create(:message, chat: chat, content: '{"preview": "Preview content"}')
      expect(message.preview).to eq('Preview content')
    end

    it 'returns nil if content is not valid JSON' do
      message = create(:message, chat: chat, content: 'invalid json')
      expect(message.preview).to be_nil
    end

    it 'returns nil if preview key is not present in the content' do
      message = create(:message, chat: chat, content: '{"sql": "SELECT * FROM users"}')
      expect(message.preview).to be_nil
    end
  end

  describe '#compiled' do
    it 'compiles content if compiled_content is nil' do
      message = create(:message, chat: chat, content: 'Some content')
      allow(message).to receive(:compiled_content).and_return(nil)
      allow(message).to receive(:compile_content).and_call_original
    end

    it 'returns compiled_content if already compiled' do
      message = create(:message, chat: chat, compiled_content: 'Compiled content')
      expect(message.compiled).to eq('Compiled content')
    end
  end

  describe '#compile_content' do
    it 'sets compiled_content to rendered markdown if content_changed?' do
      message = build(:message, chat: chat, content: 'Some content')
      allow(message).to receive(:content_changed?).and_return(true)
      message.send(:compile_content)
      expect(message.compile_content).to eq('Some content')
    end

    it 'does nothing if content has not changed' do
      message = build(:message, chat: chat, content: 'Some content')
      allow(message).to receive(:content_changed?).and_return(false)
      expect {
        message.send(:compile_content)
      }.not_to change(message, :compile_content)
    end
  end
end
