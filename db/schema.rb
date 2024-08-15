# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_15_034951) do
  create_table "chats", force: :cascade do |t|
    t.string "name"
    t.integer "data_source_id", null: false
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_source_id"], name: "index_chats_on_data_source_id"
    t.index ["slug"], name: "index_chats_on_slug", unique: true
  end

  create_table "data_sources", force: :cascade do |t|
    t.string "adapter", null: false
    t.string "host"
    t.integer "port"
    t.string "database"
    t.string "username"
    t.string "password"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "connected", default: false, null: false
    t.json "schema", default: {}, null: false
    t.string "slug"
    t.string "autocomplete_schema"
    t.index ["slug"], name: "index_data_sources_on_slug", unique: true
    t.index ["user_id"], name: "index_data_sources_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "role"
    t.text "content"
    t.integer "chat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "queries", force: :cascade do |t|
    t.string "sql"
    t.integer "data_source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "slug"
    t.index ["data_source_id"], name: "index_queries_on_data_source_id"
  end

  create_table "tables", force: :cascade do |t|
    t.string "name", null: false
    t.integer "data_source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["data_source_id", "name"], name: "index_tables_on_data_source_id_and_name", unique: true
    t.index ["data_source_id"], name: "index_tables_on_data_source_id"
    t.index ["slug"], name: "index_tables_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "image"
    t.string "ai_url"
    t.string "ai_model"
    t.string "ai_api_key"
    t.boolean "darkmode", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "data_sources"
  add_foreign_key "data_sources", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "queries", "data_sources"
  add_foreign_key "tables", "data_sources"
end
