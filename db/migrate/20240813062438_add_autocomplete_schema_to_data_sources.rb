# frozen_string_literal: true

class AddAutocompleteSchemaToDataSources < ActiveRecord::Migration[7.1]
  def change
    add_column :data_sources, :autocomplete_schema, :string
  end
end
