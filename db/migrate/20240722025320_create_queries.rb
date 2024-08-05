# frozen_string_literal: true

class CreateQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :queries do |t|
      t.string :query
      t.references :data_source, null: false, foreign_key: true

      t.timestamps
    end
  end
end
