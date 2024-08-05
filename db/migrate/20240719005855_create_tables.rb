# frozen_string_literal: true

class CreateTables < ActiveRecord::Migration[6.1]
  def change
    create_table :tables do |t|
      t.string :name, null: false
      t.json :schema, null: false, default: {}
      t.references :data_source, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tables, %i[data_source_id name], unique: true
  end
end
