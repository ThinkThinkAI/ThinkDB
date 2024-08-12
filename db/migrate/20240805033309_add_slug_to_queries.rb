class AddSlugToQueries < ActiveRecord::Migration[7.1]
  def change
    add_column :queries, :slug, :string
  end
end
