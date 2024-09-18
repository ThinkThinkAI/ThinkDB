# frozen_string_literal: true

# AIService is responsible for interacting with the AI model and client,
# processing and managing the messages received or sent via the AI client.
class AIService
  attr_reader :model, :client, :messages

  def initialize(url:, model:, api_key:)
    @url = url
    @model = model
    @api_key = api_key
    @client = OpenAI::Client.new(access_token: api_key)
    @messages = []
  end

  def add_messages(chat)
    chat.messages.each do |message|
      add_message(message.role, message.content)
    end
  end

  def add_message(role, content)
    @messages << { role:, content: }
  end

  def query_system_message(data_source)
    <<~TEXT
      You are a smart #{data_source.adapter} database.
      You will be given the schemas for the database.
      You will be asked by the user for information or to perform a task on the database.
      Your response will only be in JSON which will include up too 2 things.
      1. the query to do what was requested by the user.
      2. if the query is a delete or update then a select query to preview which records would be affected.
      The JSON will look like this. { sql: "query needed", preview: "preview query" }
      Do not include the preview if it is not necesary.
      Below is the schema for the database.
      #{data_source.schema}
    TEXT
  end

  def system_message(data_source)
    <<~TEXT
      You are a highly skilled and experienced Database Administrator (DBA) specializing in #{data_source.adapter} databases. Your role is to assist the user with any database-related inquiries or tasks, including but not limited to:

      	•	Optimizing SQL queries for performance
      	•	Setting up and managing database backups
      	•	Configuring database security settings
      	•	Providing advice on database design and architecture
      	•	Troubleshooting database issues
      	•	Offering guidance on performance tuning

      Below are the database schemas for your reference. Use them to provide accurate, detailed, and context-specific answers to the user’s questions.

      Database Schemas:

      #{data_source.schema}
    TEXT
  end

  def chat(chat)
    if chat.qchat?
      add_message('system', query_system_message(chat.data_source))
    else
      add_message('system', system_message(chat.data_source))
    end

    add_messages(chat)
    parameters = { model: @model, messages: @messages, temperature: 0.7 }

    response = @client.chat(parameters:)

    content = response.dig('choices', 0, 'message', 'content')

    extract_json_code_block(content)
  end

  private

  def extract_json_code_block(content)
    json_match = content.match(/```json\s*([^`]*)```/m)

    return content unless json_match

    json_string = json_match[1]

    JSON.parse(json_string)
    json_string
  rescue JSON::ParserError
    nil
  end
end
