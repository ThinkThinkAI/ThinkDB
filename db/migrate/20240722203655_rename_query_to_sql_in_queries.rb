# frozen_string_literal: true

class RenameQueryToSqlInQueries < ActiveRecord::Migration[7.1]
  def change
    rename_column :queries, :query, :sql
  end
end
