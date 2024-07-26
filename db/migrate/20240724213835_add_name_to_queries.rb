class AddNameToQueries < ActiveRecord::Migration[7.1]
  def change
    add_column :queries, :name, :string, null: false
  end
end
