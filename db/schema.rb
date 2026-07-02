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

ActiveRecord::Schema[8.1].define(version: 2026_07_02_074422) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_code"
    t.string "hostname"
    t.string "level"
    t.text "message"
    t.jsonb "metadata"
    t.bigint "service_id", null: false
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_logs_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "access_token"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "logs", "services"
end
