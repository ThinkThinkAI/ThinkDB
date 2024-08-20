require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user: user) }
  let(:chat) { create(:chat, data_source: data_source) }

  before do
    sign_in(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    context 'when chats exist' do
      it 'assigns the latest chat as @chat and renders the show template' do
        chat
        get :index, params: { data_source_id: data_source.id }
        expect(assigns(:chat)).to eq(chat)
        expect(response).to render_template(:show)
      end
    end

    context 'when no chats exist' do
      it 'creates a new chat and renders the show template' do
        expect {
          get :index, params: { data_source_id: data_source.id }
        }.to change(Chat, :count).by(1)
        expect(assigns(:chat)).to be_a(Chat)
        expect(response).to render_template(:show)
      end
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
      expect {
        get :new, params: { data_source_id: data_source.id }
      }.to change(Chat, :count).by(1)
      expect(response).to redirect_to('/chat')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) { { name: 'New Chat' } }

      it 'creates a new Chat' do
        expect {
          post :create, params: { data_source_id: data_source.id, chat: valid_attributes }
        }.to change(Chat, :count).by(1)
      end

      it 'redirects to the created chat' do
        post :create, params: { data_source_id: data_source.id, chat: valid_attributes }
        expect(response).to redirect_to(data_source_chat_path(data_source, Chat.last))
        expect(flash[:notice]).to eq('Chat was successfully created.')
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not create a new Chat and renders new template' do
        post :create, params: { data_source_id: data_source.id, chat: invalid_attributes }
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

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Chat' } }

      it 'updates the requested chat' do
        put :update, params: { data_source_id: data_source.id, id: chat.id, chat: new_attributes }
        chat.reload
        expect(chat.name).to eq('Updated Chat')
      end

      it 'redirects to the chat' do
        put :update, params: { data_source_id: data_source.id, id: chat.id, chat: new_attributes }
        expect(response).to redirect_to(data_source_chat_path(data_source, chat))
        expect(flash[:notice]).to eq('Chat was successfully updated.')
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the chat and renders edit template' do
        put :update, params: { data_source_id: data_source.id, id: chat.id, chat: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested chat' do
      chat
      expect {
        delete :destroy, params: { data_source_id: data_source.id, id: chat.id }
      }.to change(Chat, :count).by(-1)
    end

    it 'redirects to chats list' do
      delete :destroy, params: { data_source_id: data_source.id, id: chat.id }
      expect(response).to redirect_to(data_source_chats_path(data_source))
      expect(flash[:notice]).to eq('Chat was successfully destroyed.')
    end
  end
end
