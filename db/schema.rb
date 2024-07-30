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

ActiveRecord::Schema[7.1].define(version: 2024_07_30_195937) do
  create_table "api_keys", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", force: :cascade do |t|
    t.string "name"
    t.string "repository_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
  end

  create_table "connections", force: :cascade do |t|
    t.string "provider"
    t.text "key"
    t.datetime "last_connected_at"
    t.integer "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_connections_on_application_id"
  end

  create_table "deploys", force: :cascade do |t|
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
  end

  create_table "destinations", force: :cascade do |t|
    t.string "url"
    t.string "name"
    t.string "branch", default: "main"
    t.integer "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "public_key"
    t.text "private_key"
    t.index ["application_id"], name: "index_destinations_on_application_id"
  end

  create_table "servers", force: :cascade do |t|
    t.integer "destination_id", null: false
    t.string "host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_connected_at"
    t.index ["destination_id", "host"], name: "index_servers_on_destination_id_and_host", unique: true
    t.index ["destination_id"], name: "index_servers_on_destination_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "connections", "applications"
  add_foreign_key "destinations", "applications"
  add_foreign_key "servers", "destinations"
end
