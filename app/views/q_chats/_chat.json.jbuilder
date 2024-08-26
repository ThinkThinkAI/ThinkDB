json.extract! chat, :id, :name, :data_source_id, :slug, :created_at, :updated_at
json.url chat_url(chat, format: :json)
