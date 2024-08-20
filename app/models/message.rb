class SqlRender < Redcarpet::Render::HTML
  # def initialize(message_id)
  #   @message_id = message_id
  #   super()
  # end

  # def block_code(code, language)
  #   puts code
  #   "#{code}.#{language}"
  # end

  # def codespan(code)
  #   if code.start_with?("sql\n")
  #     sql_code = code.sub(/^sql\n/, '').sub(/;$/, '').strip
  #     puts "SQL CODE: #{sql_code}"
  #     ApplicationController.render(partial: 'queries/card_output',
  #                                  locals: {
  #                                    sql: sql_code,
  #                                    adjustment: 32,
  #                                    data_grid_id: "dataGrid-#{@message_id}"
  #                                  })
  #   else
  #     code
  #     # super(code)
  #   end
  # end
end

class Message < ApplicationRecord
  belongs_to :chat

  validates :role, presence: true
  validates :content, presence: true

  after_create :update_chat_name

  def sql
    parsed_content['sql']
  end

  def preview
    parsed_content['preview']
  end

  def parsed_content
    JSON.parse(content)
  rescue JSON::ParserError
    {}
  end

  def compile_content
    return unless content_changed?

    # markdown = Redcarpet::Markdown.new(SqlRender.new, autolink: true, tables: true)
    self.compiled_content = content # markdown.render(content)
  end

  def compiled
    compile_content if compiled_content.nil?

    compiled_content
  end

  def update_chat_name
    chat.update(name: content) if role == "user"
  end
end
