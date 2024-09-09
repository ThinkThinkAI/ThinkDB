# frozen_string_literal: true

class AddTypeToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :type, :string
  end
end
