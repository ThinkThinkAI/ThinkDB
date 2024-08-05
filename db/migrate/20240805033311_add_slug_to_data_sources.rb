class AddSlugToDataSources < ActiveRecord::Migration[7.1]
  def change
    add_column :data_sources, :slug, :string
    add_index :data_sources, :slug, unique: true
  end
end
