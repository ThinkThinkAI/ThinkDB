class CustomRender < Redcarpet::Render::HTML
  def block_code(code, language)
    height = code.lines.count <= 2 ? '70px' : '200px'
    "<br><textarea class=\"code-mirror-area\" data-mode=\"#{language}\" style=\"height: #{height};\">#{code}</textarea><br>"
  end
end

class Message < ApplicationRecord
  belongs_to :chat

  validates :role, presence: true
  validates :content, presence: true

  after_create :update_chat_name
  before_save :compile_content

  def qchat?
    chat.qchat?
  end

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

    if qchat?
      self.compiled_content = content
    else
      renderer = CustomRender.new(prettify: true)
      markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true, autolink: true, tables: true,
                                                   disable_indented_code_blocks: true)
      self.compiled_content = markdown.render(content)
    end
  end

  def compiled
    compile_content if compiled_content.nil?

    compiled_content
  end

  def update_chat_name
    chat.update(name: content) if role == 'user'
  end
end
