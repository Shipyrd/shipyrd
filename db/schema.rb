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

ActiveRecord::Schema[8.0].define(version: 2025_09_14_082905) do
  create_table "api_keys", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "repository_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "token"
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_applications_on_organization_id"
    t.index ["token"], name: "index_applications_on_token", unique: true
  end

  create_table "channels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "channel_type"
    t.text "events"
    t.string "owner_type"
    t.bigint "owner_id"
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_channels_on_application_id"
    t.index ["owner_type", "owner_id"], name: "index_channels_on_owner"
  end

  create_table "deploys", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "recorded_at"
    t.string "status"
    t.string "performer"
    t.string "version"
    t.string "service_version"
    t.text "hosts"
    t.string "command"
    t.string "subcommand"
    t.string "destination"
    t.string "role"
    t.integer "runtime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "service"
    t.string "commit_message"
    t.bigint "application_id", null: false
    t.index ["application_id"], name: "index_deploys_on_application_id"
  end

  create_table "destinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "url"
    t.string "name"
    t.string "branch", default: "main"
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "recipe_updated_at"
    t.text "base_recipe"
    t.text "recipe"
    t.datetime "recipe_last_processed_at"
    t.integer "servers_count", default: 0
    t.datetime "locked_at"
    t.integer "locked_by_user_id"
    t.index ["application_id", "name"], name: "index_destinations_on_application_id_and_name"
    t.index ["application_id"], name: "index_destinations_on_application_id"
  end

  create_table "invite_links", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "expires_at"
    t.datetime "deactivated_at"
    t.integer "role"
    t.string "code"
    t.bigint "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["code"], name: "index_invite_links_on_code", unique: true
    t.index ["creator_id"], name: "index_invite_links_on_creator_id"
  end

  create_table "memberships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "event"
    t.bigint "destination_id", null: false
    t.text "details"
    t.bigint "channel_id", null: false
    t.datetime "notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_notifications_on_channel_id"
    t.index ["destination_id"], name: "index_notifications_on_destination_id"
  end

  create_table "oauth_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "application_id", null: false
    t.integer "provider"
    t.text "token"
    t.text "refresh_token"
    t.datetime "expires_at"
    t.string "scope"
    t.text "extra_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_oauth_tokens_on_application_id"
    t.index ["user_id"], name: "index_oauth_tokens_on_user_id"
  end

  create_table "organizations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.integer "applications_count", default: 0
    t.integer "users_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "runners", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "server_id"
    t.bigint "destination_id"
    t.string "command"
    t.string "full_command"
    t.text "output"
    t.text "error"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "destination_id", null: false
    t.string "host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_connected_at"
    t.index ["destination_id", "host"], name: "index_servers_on_destination_id_and_host", unique: true
    t.index ["destination_id"], name: "index_servers_on_destination_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.boolean "system_admin"
    t.string "token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  create_table "webhooks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "url"
    t.bigint "user_id", null: false
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_webhooks_on_application_id"
    t.index ["user_id"], name: "index_webhooks_on_user_id"
  end

  add_foreign_key "channels", "applications"
  add_foreign_key "destinations", "applications"
  add_foreign_key "invite_links", "users", column: "creator_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "notifications", "channels"
  add_foreign_key "notifications", "destinations"
  add_foreign_key "oauth_tokens", "applications"
  add_foreign_key "oauth_tokens", "users"
  add_foreign_key "servers", "destinations"
  add_foreign_key "webhooks", "applications"
  add_foreign_key "webhooks", "users"
end
