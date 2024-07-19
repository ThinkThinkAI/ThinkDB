# frozen_string_literal: true

class AddConnectedToDataSources < ActiveRecord::Migration[7.1]
  def change
    add_column :data_sources, :connected, :boolean, default: false, null: false
  end
end
