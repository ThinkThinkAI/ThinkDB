class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.string :name
      t.references :data_source, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
    add_index :chats, :slug, unique: true
  end
end
