# frozen_string_literal: true

class AddSlugToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :tables, :slug, :string
    add_index :tables, :slug, unique: true
  end
end
