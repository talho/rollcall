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

ActiveRecord::Schema.define(version: 20150324220613) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alarm_queries_school_districts", id: false, force: :cascade do |t|
    t.integer "alarm_query_id",     null: false
    t.integer "school_district_id", null: false
  end

  create_table "alarm_queries_schools", id: false, force: :cascade do |t|
    t.integer "alarm_query_id", null: false
    t.integer "school_id",      null: false
  end

  create_table "alarms", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "attendance_deviation"
    t.integer  "ili_threshold"
    t.integer  "confirmed_ili_threshold"
    t.integer  "measles_threshold"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "alarms", ["user_id"], name: "index_alarms_on_user_id", using: :btree

  create_table "alert_ack_logs", force: :cascade do |t|
    t.integer  "alert_id",                             null: false
    t.string   "item_type",    limit: 255,             null: false
    t.string   "item",         limit: 255
    t.integer  "acks",                                 null: false
    t.integer  "total",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",             default: 0, null: false
    t.string   "alert_type",   limit: 255
  end

  add_index "alert_ack_logs", ["alert_id"], name: "index_alert_ack_logs_on_alert_id", using: :btree
  add_index "alert_ack_logs", ["id"], name: "index_alert_ack_logs_on_id", using: :btree
  add_index "alert_ack_logs", ["item_type"], name: "index_alert_ack_logs_on_item_type", using: :btree

  create_table "alert_attempts", force: :cascade do |t|
    t.integer  "alert_id"
    t.integer  "user_id"
    t.datetime "requested_at"
    t.datetime "acknowledged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "token",                             limit: 255
    t.integer  "jurisdiction_id"
    t.integer  "acknowledged_alert_device_type_id"
    t.integer  "call_down_response"
    t.integer  "lock_version",                                  default: 0, null: false
    t.string   "alert_type",                        limit: 255
  end

  add_index "alert_attempts", ["acknowledged_alert_device_type_id"], name: "index_alert_attempts_on_acknowledged_alert_device_type_id", using: :btree
  add_index "alert_attempts", ["alert_id", "token"], name: "index_alert_attempts_on_alert_id_and_token", using: :btree
  add_index "alert_attempts", ["alert_id"], name: "index_alert_attempts_on_alert_id", using: :btree
  add_index "alert_attempts", ["id"], name: "index_alert_attempts_on_id", using: :btree
  add_index "alert_attempts", ["jurisdiction_id"], name: "index_alert_attempts_on_jurisdiction_id", using: :btree
  add_index "alert_attempts", ["organization_id"], name: "index_alert_attempts_on_organization_id", using: :btree
  add_index "alert_attempts", ["token", "alert_id"], name: "index_alert_attempts_on_token_and_alert_id", using: :btree
  add_index "alert_attempts", ["user_id"], name: "index_alert_attempts_on_user_id", using: :btree

  create_table "alert_device_types", force: :cascade do |t|
    t.integer  "alert_id"
    t.string   "device",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",             default: 0, null: false
    t.string   "alert_type",   limit: 255
  end

  add_index "alert_device_types", ["alert_id"], name: "index_alert_device_types_on_alert_id", using: :btree
  add_index "alert_device_types", ["id"], name: "index_alert_device_types_on_id", using: :btree

  create_table "alerts", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "message",                  default: ""
    t.boolean  "acknowledge"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message_type", limit: 255
    t.string   "program_type", limit: 255
    t.string   "alert_type",   limit: 255
  end

  add_index "alerts", ["author_id"], name: "index_alerts_on_author_id", using: :btree
  add_index "alerts", ["id"], name: "index_alerts_on_id", using: :btree

  create_table "apps", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "domains",              limit: 255
    t.integer  "public_role_id"
    t.integer  "root_jurisdiction_id"
    t.string   "logo_file_name",       limit: 255
    t.string   "tiny_logo_file_name",  limit: 255
    t.string   "about_label",          limit: 255
    t.text     "about_text"
    t.string   "help_email",           limit: 255
    t.string   "new_user_path",        limit: 255
    t.text     "login_text"
    t.boolean  "is_default",                       default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "info_path",            limit: 255
    t.string   "title",                limit: 255
  end

  create_table "articles", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "pub_date"
    t.string   "title",        limit: 255
    t.text     "lede"
    t.text     "body"
    t.boolean  "visible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "articles", ["author_id"], name: "index_articles_on_author_id", using: :btree
  add_index "articles", ["id"], name: "index_articles_on_id", using: :btree

  create_table "audiences", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.integer  "owner_id"
    t.string   "scope",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_jurisdiction_id"
    t.string   "type",                  limit: 255
    t.integer  "lock_version",                      default: 0, null: false
  end

  add_index "audiences", ["id", "type"], name: "index_audiences_on_id_and_type", using: :btree
  add_index "audiences", ["owner_id"], name: "index_audiences_on_owner_id", using: :btree
  add_index "audiences", ["owner_jurisdiction_id"], name: "index_audiences_on_owner_jurisdiction_id", using: :btree
  add_index "audiences", ["scope"], name: "index_audiences_on_scope", using: :btree

  create_table "audiences_dashboards", force: :cascade do |t|
    t.integer  "audience_id"
    t.integer  "dashboard_id"
    t.integer  "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audiences_dashboards", ["audience_id", "dashboard_id"], name: "dashboard_audience_dashboard_index", using: :btree
  add_index "audiences_dashboards", ["role"], name: "index_audiences_dashboards_on_role", using: :btree

  create_table "audiences_jurisdictions", id: false, force: :cascade do |t|
    t.integer "audience_id"
    t.integer "jurisdiction_id"
  end

  add_index "audiences_jurisdictions", ["audience_id"], name: "index_audiences_jurisdictions_on_audience_id", using: :btree
  add_index "audiences_jurisdictions", ["jurisdiction_id"], name: "index_audiences_jurisdictions_on_jurisdiction_id", using: :btree

  create_table "audiences_roles", id: false, force: :cascade do |t|
    t.integer "audience_id"
    t.integer "role_id"
  end

  add_index "audiences_roles", ["audience_id"], name: "index_audiences_roles_on_audience_id", using: :btree
  add_index "audiences_roles", ["role_id"], name: "index_audiences_roles_on_role_id", using: :btree

  create_table "audiences_sub_audiences", id: false, force: :cascade do |t|
    t.integer "audience_id"
    t.integer "sub_audience_id"
  end

  add_index "audiences_sub_audiences", ["audience_id", "sub_audience_id"], name: "audience_sub_audience_uniq_index", using: :btree

  create_table "audiences_users", id: false, force: :cascade do |t|
    t.integer "audience_id"
    t.integer "user_id"
  end

  add_index "audiences_users", ["audience_id"], name: "index_audiences_users_on_audience_id", using: :btree
  add_index "audiences_users", ["user_id"], name: "index_audiences_users_on_user_id", using: :btree

  create_table "bdrb_job_queues", force: :cascade do |t|
    t.text     "args"
    t.string   "worker_name",    limit: 255
    t.string   "worker_method",  limit: 255
    t.string   "job_key",        limit: 255
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag",            limit: 255
    t.string   "submitter_info", limit: 255
    t.string   "runner_info",    limit: 255
    t.string   "worker_key",     limit: 255
    t.datetime "scheduled_at"
  end

  create_table "dashboards", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "columns"
    t.integer  "draft_columns"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "application_default",             default: false
  end

  create_table "dashboards_portlets", force: :cascade do |t|
    t.integer  "dashboard_id"
    t.integer  "portlet_id"
    t.boolean  "draft",        default: true
    t.integer  "column"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence",     default: 0
  end

  add_index "dashboards_portlets", ["dashboard_id", "portlet_id", "draft"], name: "dashboard_portlet_draft_index", using: :btree

  create_table "delayed_job_checks", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer  "device_id"
    t.datetime "delivered_at"
    t.datetime "sys_acknowledged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "alert_attempt_id"
    t.integer  "lock_version",        default: 0, null: false
  end

  add_index "deliveries", ["alert_attempt_id"], name: "index_deliveries_on_alert_attempt_id", using: :btree
  add_index "deliveries", ["device_id"], name: "index_deliveries_on_device_id", using: :btree
  add_index "deliveries", ["id"], name: "index_deliveries_on_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.integer "user_id"
    t.string  "type",          limit: 255
    t.string  "description",   limit: 255
    t.string  "name",          limit: 255
    t.string  "coverage",      limit: 255
    t.boolean "emergency_use"
    t.boolean "home_use"
    t.text    "options"
    t.integer "lock_version",              default: 0, null: false
  end

  add_index "devices", ["id"], name: "index_devices_on_id", using: :btree
  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "folder_id"
    t.integer  "lock_version",                  default: 0,    null: false
    t.boolean  "delta",                         default: true
  end

  add_index "documents", ["folder_id"], name: "index_documents_on_folder_id", using: :btree
  add_index "documents", ["id"], name: "index_documents_on_id", using: :btree
  add_index "documents", ["owner_id"], name: "index_documents_on_owner_id", using: :btree
  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree

  create_table "epi_user_details", force: :cascade do |t|
    t.integer "user_id"
    t.string  "rods_database",   limit: 255, default: ""
    t.text    "rods_facilities",             default: ""
  end

  create_table "favorites", force: :cascade do |t|
    t.string   "tab_config", limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "folder_permissions", force: :cascade do |t|
    t.integer "folder_id"
    t.integer "user_id"
    t.integer "permission"
  end

  add_index "folder_permissions", ["folder_id"], name: "index_folder_permissions_on_folder_id", using: :btree
  add_index "folder_permissions", ["user_id"], name: "index_folder_permissions_on_user_id", using: :btree

  create_table "folders", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                              default: 0,    null: false
    t.integer  "audience_id"
    t.boolean  "notify_of_audience_addition"
    t.boolean  "notify_of_document_addition"
    t.boolean  "notify_of_file_download"
    t.boolean  "expire_documents",                          default: true
    t.boolean  "notify_before_document_expiry",             default: true
    t.integer  "organization_id"
  end

  add_index "folders", ["audience_id"], name: "index_folders_on_audience_id", using: :btree
  add_index "folders", ["id"], name: "index_folders_on_id", using: :btree
  add_index "folders", ["user_id"], name: "index_folders_on_user_id", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.datetime "hidden_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                      default: 0, null: false
    t.integer  "audience_id"
    t.integer  "parent_id"
    t.integer  "owner_id"
    t.integer  "moderator_audience_id"
  end

  add_index "forums", ["audience_id"], name: "index_forums_on_audience_id", using: :btree
  add_index "forums", ["id"], name: "index_forums_on_id", using: :btree

  create_table "han_alerts", id: false, force: :cascade do |t|
    t.string   "severity",                       limit: 255
    t.string   "status",                         limit: 255
    t.boolean  "sensitive"
    t.integer  "delivery_time"
    t.integer  "alert_id"
    t.datetime "sent_at"
    t.integer  "from_organization_id"
    t.string   "from_organization_name",         limit: 255
    t.string   "from_organization_oid",          limit: 255
    t.string   "identifier",                     limit: 255
    t.string   "scope",                          limit: 255
    t.string   "category",                       limit: 255
    t.string   "program",                        limit: 255
    t.string   "urgency",                        limit: 255
    t.string   "certainty",                      limit: 255
    t.string   "jurisdiction_level",             limit: 255
    t.string   "alert_references",               limit: 255
    t.integer  "from_jurisdiction_id"
    t.integer  "original_alert_id"
    t.string   "short_message",                  limit: 255
    t.string   "message_recording_file_name",    limit: 255
    t.string   "message_recording_content_type", limit: 255
    t.string   "message_recording_file_size",    limit: 255
    t.string   "distribution_reference",         limit: 255
    t.string   "caller_id",                      limit: 255
    t.string   "ack_distribution_reference",     limit: 255
    t.string   "distribution_id",                limit: 255
    t.string   "reference",                      limit: 255
    t.string   "sender_id",                      limit: 255
    t.text     "call_down_messages"
    t.boolean  "not_cross_jurisdictional",                   default: false
  end

  add_index "han_alerts", ["alert_id"], name: "index_han_alerts_on_alert_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "body"
    t.integer  "organization_id"
    t.integer  "author_id"
    t.string   "subject",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                default: 0, null: false
  end

  add_index "invitations", ["author_id"], name: "index_invitations_on_author_id", using: :btree
  add_index "invitations", ["id"], name: "index_invitations_on_id", using: :btree
  add_index "invitations", ["organization_id"], name: "index_invitations_on_organization_id", using: :btree

  create_table "invitees", force: :cascade do |t|
    t.string   "name",          limit: 255,                 null: false
    t.string   "email",         limit: 255,                 null: false
    t.boolean  "ignore",                    default: false, null: false
    t.integer  "invitation_id",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",              default: 0,     null: false
  end

  add_index "invitees", ["id"], name: "index_invitees_on_id", using: :btree
  add_index "invitees", ["invitation_id"], name: "index_invitees_on_invitation_id", using: :btree

  create_table "jurisdictions", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "phin_oid",               limit: 255
    t.string   "description",            limit: 255
    t.string   "fax",                    limit: 255
    t.string   "locality",               limit: 255
    t.string   "postal_code",            limit: 255
    t.string   "state",                  limit: 255
    t.string   "street",                 limit: 255
    t.string   "phone",                  limit: 255
    t.string   "county",                 limit: 255
    t.string   "alerting_jurisdictions", limit: 255
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fips_code",              limit: 255
    t.boolean  "foreign",                            default: false, null: false
    t.integer  "lock_version",                       default: 0,     null: false
  end

  add_index "jurisdictions", ["fips_code"], name: "index_jurisdictions_on_fips_code", using: :btree
  add_index "jurisdictions", ["id"], name: "index_jurisdictions_on_id", using: :btree
  add_index "jurisdictions", ["lft"], name: "index_jurisdictions_on_lft", using: :btree
  add_index "jurisdictions", ["name"], name: "index_jurisdictions_on_name", using: :btree
  add_index "jurisdictions", ["parent_id"], name: "index_jurisdictions_on_parent_id", using: :btree
  add_index "jurisdictions", ["rgt"], name: "index_jurisdictions_on_rgt", using: :btree

  create_table "jurisdictions_organizations", id: false, force: :cascade do |t|
    t.integer "jurisdiction_id"
    t.integer "organization_id"
  end

  create_table "message_notification_response", force: :cascade do |t|
    t.string  "response_id",  limit: 255
    t.integer "lock_version",             default: 0, null: false
    t.string  "message_id",   limit: 255
    t.text    "response"
  end

  create_table "organization_membership_requests", force: :cascade do |t|
    t.integer "organization_id",             null: false
    t.integer "user_id",                     null: false
    t.integer "approver_id"
    t.integer "requester_id"
    t.integer "lock_version",    default: 0, null: false
  end

  add_index "organization_membership_requests", ["approver_id"], name: "index_organization_membership_requests_on_approver_id", using: :btree
  add_index "organization_membership_requests", ["id"], name: "index_organization_membership_requests_on_id", using: :btree
  add_index "organization_membership_requests", ["organization_id"], name: "index_organization_membership_requests_on_organization_id", using: :btree
  add_index "organization_membership_requests", ["requester_id"], name: "index_organization_membership_requests_on_requester_id", using: :btree
  add_index "organization_membership_requests", ["user_id"], name: "index_organization_membership_requests_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "phin_oid",                  limit: 255
    t.text     "description"
    t.string   "fax",                       limit: 255
    t.string   "locality",                  limit: 255
    t.string   "postal_code",               limit: 255
    t.string   "state",                     limit: 255
    t.string   "street",                    limit: 255
    t.string   "phone",                     limit: 255
    t.string   "alerting_jurisdictions",    limit: 255
    t.string   "primary_organization_type", limit: 255
    t.string   "type",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "foreign",                               default: false, null: false
    t.string   "queue",                     limit: 255
    t.string   "distribution_email",        limit: 255
    t.boolean  "approved",                              default: false
    t.string   "token",                     limit: 128
    t.boolean  "email_confirmed",                       default: false, null: false
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "lock_version",                          default: 0,     null: false
  end

  add_index "organizations", ["id"], name: "index_organizations_on_id", using: :btree
  add_index "organizations", ["phin_oid"], name: "index_organizations_on_phin_oid", using: :btree
  add_index "organizations", ["token"], name: "index_organizations_on_token", using: :btree

  create_table "organizations_admins", id: false, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  add_index "organizations_admins", ["organization_id"], name: "index_organizations_admins_on_organization_id", using: :btree
  add_index "organizations_admins", ["user_id"], name: "index_organizations_admins_on_user_id", using: :btree

  create_table "portlets", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "xtype",      limit: 255
    t.text     "config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_schedules", force: :cascade do |t|
    t.string   "report_type",  limit: 255
    t.boolean  "days_of_week",             default: [],              array: true
    t.integer  "user_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "role_memberships", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jurisdiction_id"
    t.integer  "role_request_id"
    t.integer  "lock_version",    default: 0, null: false
  end

  add_index "role_memberships", ["id"], name: "index_role_memberships_on_id", using: :btree
  add_index "role_memberships", ["jurisdiction_id"], name: "index_role_memberships_on_jurisdiction_id", using: :btree
  add_index "role_memberships", ["role_id"], name: "index_role_memberships_on_role_id", using: :btree
  add_index "role_memberships", ["role_request_id"], name: "index_role_memberships_on_role_request_id", using: :btree
  add_index "role_memberships", ["user_id"], name: "index_role_memberships_on_user_id", using: :btree

  create_table "role_requests", force: :cascade do |t|
    t.integer  "requester_id"
    t.integer  "role_id"
    t.integer  "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jurisdiction_id"
    t.integer  "user_id"
    t.integer  "lock_version",    default: 0, null: false
  end

  add_index "role_requests", ["approver_id"], name: "index_role_requests_on_approver_id", using: :btree
  add_index "role_requests", ["id"], name: "index_role_requests_on_id", using: :btree
  add_index "role_requests", ["jurisdiction_id"], name: "index_role_requests_on_jurisdiction_id", using: :btree
  add_index "role_requests", ["requester_id"], name: "index_role_requests_on_requester_id", using: :btree
  add_index "role_requests", ["role_id"], name: "index_role_requests_on_role_id", using: :btree
  add_index "role_requests", ["user_id"], name: "index_role_requests_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "description",  limit: 255
    t.string   "phin_oid",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                   default: false
    t.boolean  "alerter"
    t.boolean  "user_role",                default: true
    t.integer  "lock_version",             default: 0,     null: false
    t.integer  "app_id"
  end

  add_index "roles", ["alerter"], name: "index_roles_on_alerter", using: :btree
  add_index "roles", ["app_id"], name: "index_roles_on_app_id", using: :btree
  add_index "roles", ["id"], name: "index_roles_on_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "rollcall_alerts", force: :cascade do |t|
    t.integer "alarm_id"
    t.integer "alert_id"
  end

  add_index "rollcall_alerts", ["alarm_id"], name: "index_rollcall_alerts_on_alarm_id", using: :btree
  add_index "rollcall_alerts", ["alert_id"], name: "index_rollcall_alerts_on_alert_id", using: :btree

  create_table "school_daily_infos", force: :cascade do |t|
    t.integer  "school_id"
    t.integer  "total_absent"
    t.integer  "total_enrolled"
    t.date     "report_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "school_daily_infos", ["id"], name: "index_school_daily_infos_on_id", using: :btree
  add_index "school_daily_infos", ["school_id"], name: "index_school_daily_infos_on_school_id", using: :btree

  create_table "school_district_daily_infos", force: :cascade do |t|
    t.date    "report_date"
    t.float   "absentee_rate"
    t.integer "total_enrollment"
    t.integer "total_absent"
    t.integer "school_district_id"
    t.integer "lock_version",       default: 0, null: false
  end

  add_index "school_district_daily_infos", ["id"], name: "index_school_district_daily_infos_on_id", using: :btree
  add_index "school_district_daily_infos", ["school_district_id"], name: "index_school_district_daily_infos_on_school_district_id", using: :btree

  create_table "school_district_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "school_district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",               default: 0
    t.string   "email"
  end

  add_index "school_district_users", ["id"], name: "index_school_district_users_on_id", using: :btree
  add_index "school_district_users", ["school_district_id"], name: "index_school_district_users_on_school_district_id", using: :btree
  add_index "school_district_users", ["user_id"], name: "index_school_district_users_on_user_id", using: :btree

  create_table "school_districts", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",             default: 0, null: false
    t.string   "state_id"
    t.string   "city"
    t.string   "county"
    t.string   "state"
  end

  add_index "school_districts", ["id"], name: "index_school_districts_on_id", using: :btree
  add_index "school_districts", ["state_id"], name: "index_school_districts_on_state_id", using: :btree

  create_table "school_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",       default: 0
    t.string   "email"
  end

  add_index "school_users", ["id"], name: "index_school_users_on_id", using: :btree
  add_index "school_users", ["school_id"], name: "index_school_users_on_school_id", using: :btree
  add_index "school_users", ["user_id"], name: "index_school_users_on_user_id", using: :btree

  create_table "schools", force: :cascade do |t|
    t.string   "display_name",       limit: 255
    t.string   "postal_code",        limit: 255
    t.integer  "school_number"
    t.integer  "school_district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                   default: 0, null: false
    t.integer  "tea_id"
    t.string   "school_type",        limit: 255
    t.float    "gmap_lat"
    t.float    "gmap_lng"
    t.string   "gmap_addr",          limit: 255
  end

  add_index "schools", ["display_name"], name: "schools_display_name", using: :btree
  add_index "schools", ["id"], name: "index_schools_on_id", using: :btree
  add_index "schools", ["school_district_id"], name: "index_schools_on_school_district_id", using: :btree
  add_index "schools", ["tea_id"], name: "index_schools_on_tea_id", using: :btree

  create_table "student_daily_infos", force: :cascade do |t|
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

  add_index "student_daily_infos", ["id"], name: "index_student_daily_infos_on_id", using: :btree
  add_index "student_daily_infos", ["student_id"], name: "index_student_daily_infos_on_student_id", using: :btree

  create_table "student_reported_symptoms", force: :cascade do |t|
    t.integer "symptom_id"
    t.integer "student_daily_info_id"
  end

  add_index "student_reported_symptoms", ["student_daily_info_id"], name: "rollcall_srs_sdi_id", using: :btree
  add_index "student_reported_symptoms", ["symptom_id"], name: "rollcall_srs_symptom_id", using: :btree

  create_table "students", force: :cascade do |t|
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.string   "contact_first_name", limit: 255
    t.string   "contact_last_name",  limit: 255
    t.string   "address",            limit: 255
    t.string   "zip",                limit: 255
    t.string   "gender",             limit: 1
    t.string   "phone",              limit: 255
    t.integer  "race"
    t.integer  "school_id"
    t.string   "student_number",     limit: 255
    t.date     "dob"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "students", ["id", "school_id"], name: "rollcall_students_id_school_id_idx", using: :btree
  add_index "students", ["id"], name: "index_students_on_id", using: :btree
  add_index "students", ["school_id"], name: "index_students_on_school_id", using: :btree
  add_index "students", ["school_id"], name: "rollcall_students_school_id_idx", using: :btree
  add_index "students", ["school_id"], name: "school_id_fkey", using: :btree

  create_table "symptom_tags", force: :cascade do |t|
    t.string  "match",      limit: 255
    t.integer "symptom_id"
  end

  create_table "symptoms", force: :cascade do |t|
    t.string "icd9_code", limit: 255
    t.string "name",      limit: 255
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "taggable_type", limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "deleted_at"
  end

  create_table "targets", force: :cascade do |t|
    t.integer  "audience_id"
    t.integer  "item_id"
    t.string   "item_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "targets", ["audience_id"], name: "index_targets_on_audience_id", using: :btree
  add_index "targets", ["creator_id"], name: "index_targets_on_creator_id", using: :btree
  add_index "targets", ["id"], name: "index_targets_on_id", using: :btree
  add_index "targets", ["item_id", "item_type"], name: "index_targets_on_item_id_and_item_type", using: :btree

  create_table "targets_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "target_id"
  end

  add_index "targets_users", ["target_id", "user_id"], name: "index_targets_users_on_target_id_and_user_id", using: :btree
  add_index "targets_users", ["user_id", "target_id"], name: "index_targets_users_on_user_id_and_target_id", using: :btree

  create_table "tfcc_campaign_activation_response", force: :cascade do |t|
    t.integer "alert_id"
    t.integer "activation_id"
    t.integer "campaign_id"
    t.integer "transaction_id"
    t.string  "transaction_msg",   limit: 255
    t.string  "transaction_error", limit: 255
    t.integer "lock_version",                  default: 0, null: false
  end

  create_table "topics", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "comment_id"
    t.integer  "sticky",                   default: 0
    t.datetime "locked_at"
    t.string   "name",         limit: 255
    t.text     "content"
    t.integer  "poster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "hidden_at"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "topics", ["comment_id"], name: "index_topics_on_comment_id", using: :btree
  add_index "topics", ["forum_id"], name: "index_topics_on_forum_id", using: :btree
  add_index "topics", ["id"], name: "index_topics_on_id", using: :btree
  add_index "topics", ["poster_id"], name: "index_topics_on_poster_id", using: :btree
  add_index "topics", ["sticky"], name: "index_topics_on_sticky", using: :btree
  add_index "topics", ["updated_at"], name: "index_topics_on_updated_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "last_name",              limit: 255
    t.string   "phin_oid",               limit: 255
    t.text     "description"
    t.string   "name",                   limit: 255
    t.string   "first_name",             limit: 255
    t.string   "email",                  limit: 255
    t.string   "preferred_language",     limit: 255
    t.string   "title",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     limit: 128
    t.string   "salt",                   limit: 128
    t.string   "token",                  limit: 128
    t.datetime "token_expires_at"
    t.boolean  "email_confirmed",                    default: false, null: false
    t.string   "phone",                  limit: 255
    t.boolean  "delta",                              default: true,  null: false
    t.text     "credentials"
    t.text     "bio"
    t.text     "experience"
    t.string   "employer",               limit: 255
    t.string   "photo_file_name",        limit: 255
    t.string   "photo_content_type",     limit: 255
    t.boolean  "public"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "deleted_at"
    t.string   "deleted_by",             limit: 255
    t.string   "deleted_from",           limit: 24
    t.string   "home_phone",             limit: 255
    t.string   "mobile_phone",           limit: 255
    t.string   "fax",                    limit: 255
    t.datetime "last_sign_in_at"
    t.integer  "lock_version",                       default: 0,     null: false
    t.integer  "dashboard_id"
    t.string   "confirmation_token",     limit: 128
    t.string   "remember_token",         limit: 128
    t.integer  "home_jurisdiction_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_phin_people_on_email", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["id", "confirmation_token"], name: "index_users_on_id_and_confirmation_token", using: :btree
  add_index "users", ["id", "token"], name: "index_phin_people_on_id_and_token", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["token"], name: "index_phin_people_on_token", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,                  null: false
    t.integer  "item_id",                                 null: false
    t.string   "event",      limit: 255,                  null: false
    t.string   "whodunnit",  limit: 255
    t.string   "item_desc",  limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.string   "app",        limit: 255, default: "phin"
  end

  add_index "versions", ["item_type", "item_id", "item_desc"], name: "index_versions_on_item_type_and_item_id_and_item_desc", using: :btree

  create_table "vms_alerts", force: :cascade do |t|
    t.integer "alert_id"
    t.integer "scenario_id"
  end

  add_index "vms_alerts", ["alert_id"], name: "index_vms_alerts_on_alert_id", using: :btree
  add_index "vms_alerts", ["scenario_id"], name: "index_vms_alerts_on_scenario_id", using: :btree

  create_table "vms_inventories", force: :cascade do |t|
    t.integer  "scenario_site_id"
    t.integer  "source_id"
    t.string   "name",             limit: 255
    t.boolean  "pod",                          default: false
    t.boolean  "template",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_inventories", ["scenario_site_id"], name: "index_vms_inventories_on_scenario_site_id", using: :btree

  create_table "vms_inventory_item_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_inventory_item_categories", ["name"], name: "index_vms_inventory_item_categories_on_name", unique: true, using: :btree

  create_table "vms_inventory_item_collections", force: :cascade do |t|
    t.integer  "inventory_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_inventory_item_collections", ["inventory_id"], name: "index_vms_inventory_item_collections_on_inventory_id", using: :btree
  add_index "vms_inventory_item_collections", ["status"], name: "index_vms_inventory_item_collections_on_status", using: :btree
  add_index "vms_inventory_item_collections", ["user_id"], name: "index_vms_inventory_item_collections_on_user_id", using: :btree

  create_table "vms_inventory_item_instances", force: :cascade do |t|
    t.integer  "item_collection_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_inventory_item_instances", ["item_collection_id"], name: "index_vms_inventory_item_instances_on_item_collection_id", using: :btree
  add_index "vms_inventory_item_instances", ["item_id"], name: "index_vms_inventory_item_instances_on_item_id", using: :btree

  create_table "vms_inventory_items", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "item_category_id"
    t.boolean  "consumable",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_inventory_items", ["name"], name: "index_vms_inventory_items_on_name", unique: true, using: :btree

  create_table "vms_inventory_sources", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_inventory_sources", ["name"], name: "index_vms_inventory_sources_on_name", unique: true, using: :btree

  create_table "vms_roles_scenario_sites", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "scenario_site_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vms_roles_scenario_sites", ["role_id"], name: "index_vms_roles_scenario_sites_on_role_id", using: :btree
  add_index "vms_roles_scenario_sites", ["scenario_site_id"], name: "index_vms_roles_scenario_sites_on_scenario_site_id", using: :btree

  create_table "vms_scenario_site", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "scenario_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_admin_id"
  end

  add_index "vms_scenario_site", ["scenario_id"], name: "index_vms_scenario_site_on_scenario_id", using: :btree
  add_index "vms_scenario_site", ["site_id"], name: "index_vms_scenario_site_on_site_id", using: :btree

  create_table "vms_scenarios", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "state",                  default: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vms_sites", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "address",    limit: 255
    t.string   "lat",        limit: 255
    t.string   "lng",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vms_staff", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "scenario_site_id"
    t.string   "status",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",           limit: 255, default: "manual"
    t.boolean  "checked_in",                   default: false
  end

  add_index "vms_staff", ["scenario_site_id"], name: "index_vms_staff_on_scenario_site_id", using: :btree
  add_index "vms_staff", ["status"], name: "index_vms_staff_on_status", using: :btree
  add_index "vms_staff", ["user_id", "scenario_site_id"], name: "index_vms_staff_on_user_id_and_scenario_site_id", unique: true, using: :btree
  add_index "vms_staff", ["user_id"], name: "index_vms_staff_on_user_id", using: :btree

  create_table "vms_teams", force: :cascade do |t|
    t.integer "audience_id"
    t.integer "scenario_site_id"
  end

  add_index "vms_teams", ["audience_id"], name: "index_vms_teams_on_audience_id", using: :btree
  add_index "vms_teams", ["scenario_site_id"], name: "index_vms_teams_on_scenario_site_id", using: :btree

  create_table "vms_user_rights", force: :cascade do |t|
    t.integer "scenario_id"
    t.integer "user_id"
    t.integer "permission_level"
  end

  add_index "vms_user_rights", ["scenario_id"], name: "index_vms_user_rights_on_scenario_id", using: :btree
  add_index "vms_user_rights", ["user_id"], name: "index_vms_user_rights_on_user_id", using: :btree

  create_table "vms_volunteer_roles", force: :cascade do |t|
    t.integer "alert_id"
    t.integer "volunteer_id"
    t.integer "role_id"
  end

  add_index "vms_volunteer_roles", ["alert_id"], name: "index_vms_volunteer_roles_on_alert_id", using: :btree
  add_index "vms_volunteer_roles", ["role_id"], name: "index_vms_volunteer_roles_on_role_id", using: :btree
  add_index "vms_volunteer_roles", ["volunteer_id"], name: "index_vms_volunteer_roles_on_volunteer_id", using: :btree

  create_table "vms_walkups", force: :cascade do |t|
    t.integer "scenario_site_id"
    t.string  "first_name",       limit: 255
    t.string  "last_name",        limit: 255
    t.string  "email",            limit: 255
    t.boolean "checked_in",                   default: false
  end

  add_index "vms_walkups", ["scenario_site_id"], name: "index_vms_walkups_on_scenario_site_id", using: :btree

  add_foreign_key "alarms", "users"
  add_foreign_key "students", "schools", name: "rollcall_students_school_id_fkey"
end
