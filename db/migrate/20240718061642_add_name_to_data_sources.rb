# frozen_string_literal: true

class AddNameToDataSources < ActiveRecord::Migration[7.1]
  def change
    add_column :data_sources, :name, :string
  end
end
