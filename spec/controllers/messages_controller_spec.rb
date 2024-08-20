require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user: user) }
  let(:chat) { create(:chat, data_source: data_source) }
  let(:message) { create(:message, chat: chat) }

  before do
    sign_in(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(user).to receive(:connected_data_source).and_return(data_source)
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) { { role: 'user', content: 'Hello, world!' } }

      it 'responds to turbo_stream format' do
        post :create, params: { chat_id: chat.friendly_id, message: valid_attributes }, format: :turbo_stream
        expect(response.content_type).to eq "text/vnd.turbo-stream.html; charset=utf-8"
      end

      it 'responds to html format with a redirect' do
        post :create, params: { chat_id: chat.friendly_id, message: valid_attributes }
        expect(response).to redirect_to(data_source_chat_path(data_source, chat))
        expect(flash[:notice]).to eq('Message sent!')
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { role: 'user', content: '' } }

      it 'responds with turbo_stream format' do
        post :create, params: { chat_id: chat.friendly_id, message: invalid_attributes }, format: :turbo_stream
        expect(response.content_type).to eq "text/vnd.turbo-stream.html; charset=utf-8"
      end

      it 'redirects to chat path with an alert in html format' do
        post :create, params: { chat_id: chat.friendly_id, message: invalid_attributes }
        expect(response).to redirect_to(data_source_chat_path(data_source, chat))
        expect(flash[:alert]).to eq('Message could not be sent!')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested message' do
      message # Ensure the message is created before the delete action
      expect {
        delete :destroy, params: { chat_id: chat.friendly_id, id: message.id }
      }.to change(Message, :count).by(-1)
    end

    it 'redirects to the chat' do
      delete :destroy, params: { chat_id: chat.friendly_id, id: message.id }
      expect(response).to redirect_to(data_source_chat_path(data_source, chat))
      expect(flash[:notice]).to eq('Message was successfully destroyed.')
    end
  end
end
