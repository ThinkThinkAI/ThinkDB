# frozen_string_literal: true

require 'ruby-handlebars'

# PromptGeneratorService generates prompts using Handlebars templates.
class PromptGeneratorService
  TEMPLATE = 'Hello, my name is {{name}} and I am {{age}} years old.'

  def initialize
    @handlebars = Handlebars::Handlebars.new
  end

  def generate_prompt(context)
    @handlebars.compile(TEMPLATE).call(context)
  end
end
