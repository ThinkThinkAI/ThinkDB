# frozen_string_literal: true

json.array! @chats, partial: 'chats/chat', as: :chat
