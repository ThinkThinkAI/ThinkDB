# frozen_string_literal: true

class AddNameImageToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_column :users, :image, :string
  end
end
