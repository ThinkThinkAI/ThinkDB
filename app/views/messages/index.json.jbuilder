# frozen_string_literal: true

json.array! @messages, partial: 'messages/message', as: :message
