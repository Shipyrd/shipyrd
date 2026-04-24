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

ActiveRecord::Schema[8.1].define(version: 2026_04_17_153411) do
  create_table "ahoy_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "started_at"
    t.bigint "user_id"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "api_keys", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
  end

  create_table "applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "badge_key"
    t.datetime "created_at", null: false
    t.string "key"
    t.string "name"
    t.bigint "organization_id"
    t.string "repository_url"
    t.string "service"
    t.integer "sort_order", default: 0, null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_applications_on_organization_id"
    t.index ["token"], name: "index_applications_on_token", unique: true
  end

  create_table "blazer_audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at"
    t.string "data_source"
    t.bigint "query_id"
    t.text "statement"
    t.bigint "user_id"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.text "emails"
    t.datetime "last_run_at"
    t.text "message"
    t.bigint "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dashboard_id"
    t.integer "position"
    t.bigint "query_id"
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "channels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.integer "channel_type"
    t.datetime "created_at", null: false
    t.text "events"
    t.bigint "owner_id"
    t.string "owner_type"
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_channels_on_application_id"
    t.index ["owner_type", "owner_id"], name: "index_channels_on_owner"
  end

  create_table "deploys", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.string "command"
    t.string "commit_message"
    t.datetime "created_at", null: false
    t.string "destination"
    t.text "hosts"
    t.string "performer"
    t.datetime "recorded_at"
    t.string "role"
    t.integer "runtime"
    t.string "service"
    t.string "service_version"
    t.string "status"
    t.string "subcommand"
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["application_id"], name: "index_deploys_on_application_id"
  end

  create_table "destinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.boolean "auto_lock_outside_business_hours", default: false
    t.text "base_recipe"
    t.boolean "block_deploys"
    t.string "branch", default: "main"
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.integer "locked_by_user_id"
    t.string "name"
    t.text "recipe"
    t.datetime "recipe_last_processed_at"
    t.datetime "recipe_updated_at"
    t.integer "servers_count", default: 0
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["application_id", "name"], name: "index_destinations_on_application_id_and_name"
    t.index ["application_id"], name: "index_destinations_on_application_id"
  end

  create_table "email_addresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["email"], name: "index_email_addresses_on_email"
    t.index ["user_id"], name: "index_email_addresses_on_user_id"
  end

  create_table "incoming_webhooks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "provider"
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_incoming_webhooks_on_application_id"
  end

  create_table "invite_links", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.datetime "deactivated_at"
    t.datetime "expires_at"
    t.bigint "organization_id"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_invite_links_on_code", unique: true
    t.index ["creator_id"], name: "index_invite_links_on_creator_id"
  end

  create_table "memberships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "role", default: 0
    t.string "slack_user_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id", "slack_user_id"], name: "index_memberships_on_organization_id_and_slack_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.datetime "created_at", null: false
    t.bigint "destination_id", null: false
    t.text "details"
    t.string "event"
    t.datetime "notified_at"
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_notifications_on_channel_id"
    t.index ["destination_id"], name: "index_notifications_on_destination_id"
  end

  create_table "oauth_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.text "extra_data"
    t.integer "provider"
    t.text "refresh_token"
    t.string "scope"
    t.text "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["application_id"], name: "index_oauth_tokens_on_application_id"
    t.index ["user_id"], name: "index_oauth_tokens_on_user_id"
  end

  create_table "organizations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "applications_count", default: 0
    t.integer "business_hours_end", default: 17
    t.integer "business_hours_start", default: 9
    t.datetime "created_at", null: false
    t.datetime "last_payment_at"
    t.string "name"
    t.text "slack_access_token"
    t.string "slack_team_id"
    t.string "slack_team_name"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "stripe_subscription_status"
    t.string "time_zone"
    t.string "token"
    t.datetime "updated_at", null: false
    t.integer "users_count", default: 0
    t.index ["slack_team_id"], name: "index_organizations_on_slack_team_id", unique: true
    t.index ["stripe_customer_id"], name: "index_organizations_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_organizations_on_stripe_subscription_id"
  end

  create_table "runners", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "command"
    t.datetime "created_at", null: false
    t.bigint "destination_id"
    t.text "error"
    t.datetime "finished_at"
    t.string "full_command"
    t.text "output"
    t.bigint "server_id"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
  end

  create_table "servers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "destination_id", null: false
    t.string "host"
    t.datetime "last_connected_at"
    t.datetime "updated_at", null: false
    t.index ["destination_id", "host"], name: "index_servers_on_destination_id_and_host", unique: true
    t.index ["destination_id"], name: "index_servers_on_destination_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "email_verified_at"
    t.string "name"
    t.string "password_digest"
    t.boolean "system_admin"
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "username"
    t.boolean "weekly_deploy_summary", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  create_table "webhooks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "url"
    t.bigint "user_id", null: false
    t.index ["application_id"], name: "index_webhooks_on_application_id"
    t.index ["user_id"], name: "index_webhooks_on_user_id"
  end

  add_foreign_key "channels", "applications"
  add_foreign_key "destinations", "applications"
  add_foreign_key "email_addresses", "users"
  add_foreign_key "incoming_webhooks", "applications"
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
