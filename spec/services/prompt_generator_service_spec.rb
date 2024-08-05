# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptGeneratorService do
  describe '#generate_prompt' do
    let(:context) { { 'name' => 'Alice', 'age' => '30' } }
    let(:expected_prompt) { 'Hello, my name is Alice and I am 30 years old.' }

    it 'generates a prompt from the template with the given context' do
      prompt_generator = PromptGeneratorService.new
      result = prompt_generator.generate_prompt(context)

      expect(result).to eq(expected_prompt)
    end
  end
end
