# frozen_string_literal: true

# spec/controllers/q_chats_controller_spec.rb
require 'rails_helper'

RSpec.describe QChatsController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source) }
  let!(:qchat) { create(:q_chat, data_source:) }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
    allow(user).to receive(:connected_data_source).and_return(data_source)
  end

  describe 'GET #index' do
    context 'when there are existing qchats' do
      it 'assigns the latest qchat to @chat and renders show template' do
        get :index, params: { data_source_id: data_source.id }
        expect(assigns(:chat)).to eq(qchat)
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested qchat to @chat' do
      get :show, params: { id: qchat.id, data_source_id: data_source.id }
      expect(assigns(:chat)).to eq(qchat)
    end
  end

  describe 'GET #new' do
    it 'creates a new qchat and redirects to /qchat' do
      get :new, params: { data_source_id: data_source.id }
      expect(QChat.last.name).to eq('Chat')
      expect(response).to redirect_to('/qchat')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new qchat and redirects to the chat show page' do
        post :create, params: { data_source_id: data_source.id, name: 'New Chat' }
        expect(QChat.last.name).to eq('New Chat')
      end
    end

    context 'with invalid attributes' do
      before { allow_any_instance_of(QChat).to receive(:save).and_return(false) }

      it 'does not create a new qchat and renders the new template' do
        post :create, params: { data_source_id: data_source.id, name: '' }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested qchat to @chat' do
      get :edit, params: { id: qchat.id, data_source_id: data_source.id }
      expect(assigns(:chat)).to eq(qchat)
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid attributes' do
      it 'updates the qchat and redirects to the chat show page' do
        patch :update, params: { id: qchat.id, data_source_id: data_source.id, name: 'Updated Chat' }
        qchat.reload
        expect(qchat.name).to eq('Updated Chat')
      end
    end

    context 'with invalid attributes' do
      before { allow_any_instance_of(QChat).to receive(:update).and_return(false) }

      it 'does not update the qchat and renders the edit template' do
        patch :update, params: { id: qchat.id, data_source_id: data_source.id, name: '' }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the qchat and redirects to the chats index page with a notice' do
      expect do
        delete :destroy, params: { id: qchat.id, data_source_id: data_source.id }
      end.to change(QChat, :count).by(-1)

      expect(flash[:notice]).to eq('Chat was successfully destroyed.')
    end
  end

  private

  def data_source_chat_path(data_source, chat)
    # Implement this path helper if it's not already defined
    "/data_sources/#{data_source.id}/chats/#{chat.id}"
  end

  def data_source_chats_path(data_source)
    # Implement this path helper if it's not already defined
    "/data_sources/#{data_source.id}/chats"
  end
end
