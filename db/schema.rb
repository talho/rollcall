# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150318152830) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rollcall_alarm_queries", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "severity"
    t.integer  "deviation_threshold"
    t.integer  "deviation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alarm_set"
    t.date     "start_date"
  end

  add_index "rollcall_alarm_queries", ["name"], name: "index_rollcall_alarm_queries_on_name", using: :btree
  add_index "rollcall_alarm_queries", ["user_id"], name: "index_rollcall_alarm_queries_on_user_id", using: :btree

  create_table "rollcall_alarm_queries_school_districts", id: false, force: :cascade do |t|
    t.integer "alarm_query_id",     null: false
    t.integer "school_district_id", null: false
  end

  create_table "rollcall_alarm_queries_schools", id: false, force: :cascade do |t|
    t.integer "alarm_query_id", null: false
    t.integer "school_id",      null: false
  end

  create_table "rollcall_alarms", force: :cascade do |t|
    t.integer  "school_id"
    t.integer  "alarm_query_id"
    t.float    "deviation"
    t.float    "severity"
    t.float    "absentee_rate"
    t.date     "report_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alarm_severity"
    t.boolean  "ignore_alarm",   default: false
  end

  add_index "rollcall_alarms", ["alarm_query_id"], name: "index_rollcall_alarms_on_alarm_query_id", using: :btree
  add_index "rollcall_alarms", ["school_id"], name: "index_rollcall_alarms_on_school_id", using: :btree

  create_table "rollcall_alerts", force: :cascade do |t|
    t.integer "alarm_id"
    t.integer "alert_id"
  end

  add_index "rollcall_alerts", ["alarm_id"], name: "index_rollcall_alerts_on_alarm_id", using: :btree
  add_index "rollcall_alerts", ["alert_id"], name: "index_rollcall_alerts_on_alert_id", using: :btree

  create_table "rollcall_bases", force: :cascade do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rollcall_school_daily_infos", force: :cascade do |t|
    t.integer  "school_id"
    t.integer  "total_absent"
    t.integer  "total_enrolled"
    t.date     "report_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rollcall_school_daily_infos", ["id"], name: "index_rollcall_school_daily_infos_on_id", using: :btree
  add_index "rollcall_school_daily_infos", ["school_id"], name: "index_rollcall_school_daily_infos_on_school_id", using: :btree

  create_table "rollcall_school_district_daily_infos", force: :cascade do |t|
    t.date    "report_date"
    t.float   "absentee_rate"
    t.integer "total_enrollment"
    t.integer "total_absent"
    t.integer "school_district_id"
    t.integer "lock_version",       default: 0, null: false
  end

  add_index "rollcall_school_district_daily_infos", ["id"], name: "index_rollcall_school_district_daily_infos_on_id", using: :btree
  add_index "rollcall_school_district_daily_infos", ["school_district_id"], name: "idx_daily_infos_on_school_district_id", using: :btree

  create_table "rollcall_school_districts", force: :cascade do |t|
    t.string   "name"
    t.integer  "jurisdiction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",    default: 0, null: false
    t.integer  "district_id"
  end

  add_index "rollcall_school_districts", ["district_id"], name: "index_rollcall_school_districts_on_district_id", using: :btree
  add_index "rollcall_school_districts", ["id"], name: "index_rollcall_school_districts_on_id", using: :btree
  add_index "rollcall_school_districts", ["jurisdiction_id"], name: "index_rollcall_school_districts_on_jurisdiction_id", using: :btree

  create_table "rollcall_schools", force: :cascade do |t|
    t.string   "display_name"
    t.string   "postal_code"
    t.integer  "school_number"
    t.integer  "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",  default: 0, null: false
    t.integer  "tea_id"
    t.string   "school_type"
    t.float    "gmap_lat"
    t.float    "gmap_lng"
    t.string   "gmap_addr"
  end

  add_index "rollcall_schools", ["display_name"], name: "schools_display_name", using: :btree
  add_index "rollcall_schools", ["district_id"], name: "index_rollcall_schools_on_district_id", using: :btree
  add_index "rollcall_schools", ["id"], name: "index_rollcall_schools_on_id", using: :btree
  add_index "rollcall_schools", ["tea_id"], name: "index_rollcall_schools_on_tea_id", using: :btree

  create_table "rollcall_student_daily_infos", force: :cascade do |t|
    t.date     "report_date"
    t.integer  "grade"
    t.boolean  "confirmed_illness"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cid"
    t.string   "health_year",       limit: 10
    t.date     "date_of_onset"
    t.float    "temperature"
    t.boolean  "in_school"
    t.boolean  "released"
    t.string   "diagnosis",         limit: 200
    t.string   "treatment",         limit: 200
    t.date     "follow_up"
    t.string   "doctor",            limit: 200
    t.string   "doctor_address",    limit: 200
    t.integer  "student_id"
    t.datetime "report_time"
  end

  add_index "rollcall_student_daily_infos", ["id"], name: "index_rollcall_student_daily_infos_on_id", using: :btree
  add_index "rollcall_student_daily_infos", ["student_id"], name: "index_rollcall_student_daily_infos_on_student_id", using: :btree

  create_table "rollcall_student_reported_symptoms", force: :cascade do |t|
    t.integer "symptom_id"
    t.integer "student_daily_info_id"
  end

  add_index "rollcall_student_reported_symptoms", ["student_daily_info_id"], name: "rollcall_srs_sdi_id", using: :btree
  add_index "rollcall_student_reported_symptoms", ["symptom_id"], name: "rollcall_srs_symptom_id", using: :btree

  create_table "rollcall_students", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "contact_first_name"
    t.string   "contact_last_name"
    t.string   "address"
    t.string   "zip"
    t.string   "gender",             limit: 1
    t.string   "phone"
    t.integer  "race"
    t.integer  "school_id"
    t.string   "student_number"
    t.date     "dob"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rollcall_students", ["id"], name: "index_rollcall_students_on_id", using: :btree
  add_index "rollcall_students", ["school_id"], name: "index_rollcall_students_on_school_id", using: :btree

  create_table "rollcall_symptom_tags", force: :cascade do |t|
    t.string  "match"
    t.integer "symptom_id"
  end

  create_table "rollcall_symptoms", force: :cascade do |t|
    t.string "icd9_code"
    t.string "name"
  end

  create_table "rollcall_user_school_districts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "school_district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rollcall_user_school_districts", ["id"], name: "index_rollcall_user_school_districts_on_id", using: :btree
  add_index "rollcall_user_school_districts", ["school_district_id"], name: "index_rollcall_user_school_districts_on_school_district_id", using: :btree
  add_index "rollcall_user_school_districts", ["user_id"], name: "index_rollcall_user_school_districts_on_user_id", using: :btree

  create_table "rollcall_user_schools", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rollcall_user_schools", ["id"], name: "index_rollcall_user_schools_on_id", using: :btree
  add_index "rollcall_user_schools", ["school_id"], name: "index_rollcall_user_schools_on_school_id", using: :btree
  add_index "rollcall_user_schools", ["user_id"], name: "index_rollcall_user_schools_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
