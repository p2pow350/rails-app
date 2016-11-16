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

ActiveRecord::Schema.define(version: 20161116172752) do

  create_table "carriers", force: :cascade do |t|
    t.string   "name"
    t.boolean  "is_customer"
    t.boolean  "is_supplier"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "email"
    t.integer  "rates_count", default: 0
    t.string   "currency"
    t.integer  "type"
    t.boolean  "status"
  end

  create_table "code_processes", force: :cascade do |t|
    t.integer  "zone_id"
    t.string   "carrier_zone_name"
    t.string   "prefix"
    t.string   "carrier_prefix"
    t.date     "start_date"
    t.decimal  "carrier_price1"
    t.string   "flag_update1"
    t.decimal  "carrier_price2"
    t.string   "flag_update2"
    t.decimal  "carrier_price3"
    t.string   "flag_update3"
    t.decimal  "carrier_price4"
    t.string   "flag_update4"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "code_id"
    t.integer  "carrier_id"
    t.index ["carrier_id"], name: "index_code_processes_on_carrier_id"
    t.index ["carrier_prefix"], name: "index_code_processes_on_carrier_prefix"
    t.index ["carrier_price1"], name: "index_code_processes_on_carrier_price1"
    t.index ["carrier_price2"], name: "index_code_processes_on_carrier_price2"
    t.index ["carrier_price4"], name: "index_code_processes_on_carrier_price4"
    t.index ["code_id"], name: "index_code_processes_on_code_id"
    t.index ["prefix"], name: "index_code_processes_on_prefix"
    t.index ["start_date"], name: "index_code_processes_on_start_date"
    t.index ["zone_id"], name: "index_code_processes_on_zone_id"
  end

  create_table "codes", force: :cascade do |t|
    t.string   "name"
    t.string   "prefix"
    t.integer  "zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prefix"], name: "index_codes_on_prefix"
    t.index ["zone_id"], name: "index_codes_on_zone_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.date     "start_date"
    t.string   "currency"
    t.decimal  "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "options", force: :cascade do |t|
    t.string   "area"
    t.string   "o_key"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rates", force: :cascade do |t|
    t.integer  "zone_id"
    t.integer  "carrier_id"
    t.string   "name"
    t.string   "prefix"
    t.decimal  "price_min",   precision: 5, scale: 6
    t.integer  "step"
    t.datetime "start_date"
    t.integer  "status"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "flag1"
    t.string   "flag2"
    t.string   "flag3"
    t.integer  "code_id"
    t.decimal  "found_price"
    t.index ["carrier_id"], name: "index_rates_on_carrier_id"
    t.index ["code_id"], name: "index_rates_on_code_id"
    t.index ["flag1"], name: "index_rates_on_flag1"
    t.index ["flag2"], name: "index_rates_on_flag2"
    t.index ["flag3"], name: "index_rates_on_flag3"
    t.index ["prefix"], name: "index_rates_on_prefix"
    t.index ["price_min"], name: "index_rates_on_price_min"
    t.index ["zone_id"], name: "index_rates_on_zone_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "default_locale"
    t.string   "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "zones", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "codes_count", default: 0
  end

end
