# frozen_string_literal: true

class AddAIDetailsAndDarkmodeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :ai_url, :string
    add_column :users, :ai_model, :string
    add_column :users, :ai_api_key, :string
    add_column :users, :darkmode, :boolean, default: true
  end
end
