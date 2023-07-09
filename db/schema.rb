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

ActiveRecord::Schema[7.1].define(version: 2023_07_09_013559) do
  create_table "api_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "environment"
    t.string "repository_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deploys", force: :cascade do |t|
    t.datetime "deployed_at"
    t.string "status"
    t.string "deployer"
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
  end

end
