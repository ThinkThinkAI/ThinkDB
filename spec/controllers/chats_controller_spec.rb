# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }
  let(:chat) { create(:chat, data_source:) }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
    allow(user).to receive(:connected_data_source).and_return(data_source)
  end

  describe 'GET #index' do
    it 'assigns the latest chat as @chat and renders the :show template' do
      get :index, params: { data_source_id: data_source.id }
      expect(assigns(:chat)).to eq(data_source.chats.excluding_qchats.order(created_at: :desc).first)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested chat as @chat' do
      get :show, params: { data_source_id: data_source.id, id: chat.id }
      expect(assigns(:chat)).to eq(chat)
    end
  end

  describe 'GET #new' do
    it 'creates a new chat and redirects to /chat' do
      expect do
        get :new, params: { data_source_id: data_source.id }
      end.to change(Chat, :count).by(1)
      expect(response).to redirect_to('/chat')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new chat and redirects to the chat show page' do
        expect do
          post :create, params: { data_source_id: data_source.id, chat: { name: 'Test Chat' } }
        end.to change(Chat, :count).by(1)
        expect(response).to redirect_to(data_source_chat_path(data_source, Chat.last))
      end
    end

    context 'with invalid params' do
      it 'renders the new template' do
        post :create, params: { data_source_id: data_source.id, chat: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested chat as @chat' do
      get :edit, params: { data_source_id: data_source.id, id: chat.id }
      expect(assigns(:chat)).to eq(chat)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the chat and redirects to the chat show page' do
        patch :update, params: { data_source_id: data_source.id, id: chat.id, chat: { name: 'Updated Chat' } }
        chat.reload
        expect(chat.name).to eq('Updated Chat')
        expect(response).to redirect_to(data_source_chat_path(data_source, chat))
      end
    end

    context 'with invalid params' do
      it 'renders the edit template' do
        patch :update, params: { data_source_id: data_source.id, id: chat.id, chat: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested chat and redirects to the chats index' do
      chat # ensure the chat is created before the expect block
      expect do
        delete :destroy, params: { data_source_id: data_source.id, id: chat.id }
      end.to change(Chat, :count).by(-1)
      expect(response).to redirect_to(data_source_chats_path(data_source))
    end
  end
end
