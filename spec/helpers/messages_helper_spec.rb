# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesHelper, type: :helper do
  let(:message) { create(:message) }
  let(:chat) { create(:chat) }

  describe '#render_message_partial' do
    context 'when chat is a qchat' do
      before do
        allow(chat).to receive(:qchat?).and_return(true)
        assign(:chat, chat)
      end

      it 'renders the qmessage partial' do
        expect(helper).to receive(:render).with(partial: 'messages/qmessage', object: message)
        helper.render_message_partial(message)
      end
    end

    context 'when chat is not a qchat' do
      before do
        allow(chat).to receive(:qchat?).and_return(false)
        assign(:chat, chat)
      end

      it 'renders the message partial' do
        expect(helper).to receive(:render).with(partial: 'messages/message', object: message)
        helper.render_message_partial(message)
      end
    end
  end
end
