# frozen_string_literal: true

class CreateDataSources < ActiveRecord::Migration[7.1]
  def change
    create_table :data_sources do |t|
      t.string :adapter, null: false
      t.string :host
      t.integer :port
      t.string :database
      t.string :username
      t.string :password
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
