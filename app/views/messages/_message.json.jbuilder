json.extract! message, :id, :role, :content, :chat_id, :created_at, :updated_at
json.url message_url(message, format: :json)
