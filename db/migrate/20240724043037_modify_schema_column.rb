# frozen_string_literal: true

class ModifySchemaColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :data_sources, :schema, :json, default: {}, null: false

    remove_column :tables, :schema
  end
end
