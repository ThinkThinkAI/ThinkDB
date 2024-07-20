class AIService
  attr_reader :model, :client, :messages

  def initialize(url:, model:, api_key:)
    @url = url
    @model = model
    @api_key = api_key
    @client = OpenAI::Client.new(api_key: api_key)
    @messages = []
  end

  def add_message(role, content)
    @messages << { role: role, content: content }
  end

  def chat
    response = @client.chat(parameters: {
      model: @model,
      response_format: { type: 'json_object' },
      messages: @messages,
      temperature: 0.7
    })
    response['choices']
  end
end
