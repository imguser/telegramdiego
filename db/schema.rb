# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_25_075352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "channel_accesses", force: :cascade do |t|
    t.bigint "registered_user_id", null: false
    t.bigint "channel_id", null: false
    t.boolean "valid_details", default: false
    t.boolean "matching_sku", default: false
    t.boolean "restricted", default: false
    t.boolean "banned", default: false
    t.text "reasons", default: ["new_record"], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_channel_accesses_on_channel_id"
    t.index ["registered_user_id"], name: "index_channel_accesses_on_registered_user_id"
  end

  create_table "channels", force: :cascade do |t|
    t.string "chat_id"
    t.string "name"
    t.string "username"
    t.string "invite_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "valid_sku", default: [], array: true
    t.string "access_hash"
    t.index ["chat_id"], name: "index_channels_on_chat_id"
    t.index ["invite_link"], name: "index_channels_on_invite_link"
    t.index ["username"], name: "index_channels_on_username"
  end

  create_table "global_snippets", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.boolean "is_example", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_global_snippets_on_name"
  end

  create_table "message_replies", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.text "help"
    t.string "related_link"
    t.jsonb "available_snippets", default: {}
    t.boolean "quote_message", default: false
    t.boolean "use_markdown", default: false
    t.boolean "system_required", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: false
    t.index ["name"], name: "index_message_replies_on_name"
  end

  create_table "registered_users", force: :cascade do |t|
    t.string "external_id"
    t.string "telegram_id"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "language_code", default: "en"
    t.jsonb "external_response", default: {}
    t.string "provided_email"
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_hash"
    t.text "sku", default: [], array: true
    t.datetime "sku_synchronized_at"
    t.index ["external_id"], name: "index_registered_users_on_external_id", unique: true
    t.index ["telegram_id"], name: "index_registered_users_on_telegram_id"
    t.index ["username"], name: "index_registered_users_on_username"
  end

  create_table "telegram_updates", force: :cascade do |t|
    t.string "update_id"
    t.jsonb "payload"
    t.text "content"
    t.string "content_type"
    t.boolean "pending", default: true
    t.boolean "success", default: false
    t.string "error_class"
    t.string "error_message"
    t.text "error_backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "response"
    t.index ["update_id"], name: "index_telegram_updates_on_update_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "channel_accesses", "channels"
  add_foreign_key "channel_accesses", "registered_users", on_delete: :cascade
end
