# frozen_string_literal: true

module MessagesHelper
  def render_message_partial(message)
    if @chat.qchat?
      render partial: 'messages/qmessage', object: message
    else
      render partial: 'messages/message', object: message
    end
  end
end
