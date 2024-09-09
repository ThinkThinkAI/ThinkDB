# frozen_string_literal: true

class AddContentHtmlToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :content_html, :text
  end
end
