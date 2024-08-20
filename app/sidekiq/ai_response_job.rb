class AIResponseJob
  include Sidekiq::Job

  def perform(chat_id)
    chat = Chat.find(chat_id)
    user = chat.data_source.user
    url = user.ai_url
    model = user.ai_model
    api_key = user.ai_api_key

    ai_service = AIService.new(url:, model:, api_key:)
    ai_response = ai_service.chat(chat)

    message = chat.messages.create!(content: ai_response, role: 'assistant')

    message_sql = message.preview || message.sql
    message_id = "id#{message.id}"
    ai_response = render_message(message)

    broadcast_payload = { ai_response:, message_id:, message_sql: }

    ActionCable.server.broadcast "chat_channel_#{user.id}", broadcast_payload
  end

  private

  def render_message(message)
    ApplicationController.render(
      partial: 'messages/message',
      locals: { message: }
    )
  end
end
