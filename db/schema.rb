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

ActiveRecord::Schema[6.1].define(version: 2021_04_20_074243) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "accounts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "encrypted_login"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "encrypted_login_iv"
    t.string "encrypted_password_iv"
    t.string "type", default: "QualysConfig", null: false
    t.string "encrypted_api_key"
    t.string "encrypted_api_key_iv"
    t.string "url", null: false
    t.datetime "discarded_at"
    t.string "encrypted_secret_key"
    t.string "encrypted_secret_key_iv"
    t.index ["discarded_at"], name: "index_accounts_on_discarded_at"
  end

  create_table "accounts_teams", id: false, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "team_id", null: false
    t.index ["account_id", "team_id"], name: "index_accounts_teams", unique: true
  end

  create_table "action_text_rich_texts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "actions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "state", default: 0, null: false
    t.integer "meta_state", default: 0, null: false
    t.text "name", null: false
    t.text "description"
    t.uuid "receiver_id"
    t.uuid "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.text "pmt_name"
    t.text "pmt_reference"
    t.index ["discarded_at"], name: "index_actions_on_discarded_at"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.datetime "created_at", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "aggregate_contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "aggregate_id", null: false
    t.text "text"
    t.integer "rank"
  end

  create_table "aggregates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.text "solution"
    t.integer "status"
    t.integer "severity"
    t.uuid "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind", default: 1, null: false
    t.datetime "discarded_at"
    t.integer "rank", default: 1, null: false
    t.text "scope"
    t.integer "visibility", default: 0, null: false
    t.string "impact"
    t.string "complexity"
    t.index ["discarded_at"], name: "index_aggregates_on_discarded_at"
    t.index ["report_id", "kind", "rank"], name: "index_aggregates_on_report_id_and_kind_and_rank", unique: true
  end

  create_table "aggregates_actions", id: false, force: :cascade do |t|
    t.uuid "aggregate_id"
    t.uuid "action_id"
    t.datetime "created_at"
    t.index ["aggregate_id", "action_id"], name: "index_aggregates_actions", unique: true
  end

  create_table "aggregates_references", id: false, force: :cascade do |t|
    t.uuid "aggregate_id", null: false
    t.uuid "reference_id", null: false
  end

  create_table "aggregates_vm_occurrences", id: false, force: :cascade do |t|
    t.uuid "vm_occurrence_id", null: false
    t.uuid "aggregate_id", null: false
    t.index ["vm_occurrence_id", "aggregate_id"], name: "index_aggregates_vm_occurences", unique: true
  end

  create_table "aggregates_wa_occurrences", id: false, force: :cascade do |t|
    t.uuid "wa_occurrence_id", null: false
    t.uuid "aggregate_id", null: false
    t.index ["wa_occurrence_id", "aggregate_id"], name: "index_aggregates_wa_occurences", unique: true
  end

  create_table "assets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.integer "category", null: false
    t.string "os"
    t.integer "confidentiality", default: 0, null: false
    t.integer "integrity", default: 0, null: false
    t.integer "availability", default: 0, null: false
    t.uuid "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_assets_on_discarded_at"
  end

  create_table "assets_projects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "asset_id", null: false
    t.uuid "project_id", null: false
  end

  create_table "assets_targets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "asset_id", null: false
    t.uuid "target_id", null: false
  end

  create_table "certificates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "path", default: ""
    t.integer "stars_level", default: 0
    t.integer "transparency_level", default: 2
    t.uuid "project_id", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_certificates_on_discarded_at"
  end

  create_table "certificates_languages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "language_id", null: false
    t.uuid "certificate_id", null: false
    t.string "sync_link"
    t.index ["certificate_id", "language_id"], name: "index_certificates_languages_on_certificate_id_and_language_id", unique: true
  end

  create_table "clients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "ref_identifier"
    t.string "name"
    t.string "web_url"
    t.string "internal_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.boolean "otp_mandatory", default: false, null: false
    t.index ["discarded_at"], name: "index_clients_on_discarded_at"
    t.index ["name"], name: "index_clients_on_name", unique: true
  end

  create_table "clients_contacts", id: false, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.uuid "contact_id", null: false
    t.index ["contact_id", "client_id"], name: "index_clients_contacts_on_contact_id_and_client_id", unique: true
  end

  create_table "clients_suppliers", id: false, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.uuid "supplier_id", null: false
  end

  create_table "comments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "action_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.uuid "author_id"
    t.string "author_type"
    t.index ["discarded_at"], name: "index_comments_on_discarded_at"
  end

  create_table "crons", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "cronable_id"
    t.string "cronable_type"
    t.string "value"
    t.index ["name", "cronable_type", "cronable_id"], name: "index_crons_on_name_and_res_type_and_res_id", unique: true
  end

  create_table "customizations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key"], name: "index_customizations_on_key", unique: true
  end

  create_table "dependencies", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "predecessor_id", null: false
    t.uuid "successor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_dependencies_on_discarded_at"
    t.index ["successor_id", "predecessor_id"], name: "dependencies_idx_pred_succ", unique: true
  end

  create_table "exploit_sources", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exploits", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "reference"
    t.string "description"
    t.string "link"
    t.uuid "exploit_source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference", "link", "description"], name: "index_exploits_on_reference_and_link_and_description", unique: true
  end

  create_table "exploits_vulnerabilities", id: false, force: :cascade do |t|
    t.uuid "exploit_id", null: false
    t.uuid "vulnerability_id", null: false
    t.index ["exploit_id", "vulnerability_id"], name: "index_exploits_vuln_on_exploit_id_and_vuln_id", unique: true
  end

  create_table "groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "otp_mandatory", default: false, null: false
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "idp_configs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.string "idp_metadata_url"
    t.string "idp_entity_id"
    t.datetime "discarded_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_idp_configs_on_name", unique: true
  end

  create_table "imports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "importer_id"
    t.integer "status", default: 0, null: false
    t.string "type", null: false
    t.integer "import_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "scan_launch_id"
    t.uuid "account_id"
  end

  create_table "jobs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "creator_id"
    t.string "resque_job_id"
    t.integer "progress_step", default: 0
    t.integer "progress_steps"
    t.string "clazz"
    t.string "status", default: "init"
    t.string "title"
    t.text "stacktrace"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resque_job_id"], name: "index_jobs_on_resque_job_id"
  end

  create_table "jobs_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "job_id"
    t.uuid "subscriber_id"
  end

  create_table "languages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "iso", null: false
  end

  create_table "notes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "staff_id", null: false
    t.uuid "report_id", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_notes_on_discarded_at"
  end

  create_table "notifications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "version_id"
    t.datetime "created_at"
    t.integer "subject"
    t.index ["version_id"], name: "index_notifications_on_version_id", unique: true
  end

  create_table "notifications_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "notification_id"
    t.uuid "subscriber_id"
    t.integer "state", default: 0
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_notifications_subscriptions_on_discarded_at"
    t.index ["notification_id", "subscriber_id"], name: "index_notifications_subscriptions", unique: true
  end

  create_table "pentest_reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "pentest_report_id"
    t.text "tools"
    t.text "exec_cond"
    t.text "purpose"
    t.text "results"
  end

  create_table "projects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "folder_name", default: ""
    t.uuid "language_id"
    t.boolean "auto_generate", default: false
    t.boolean "auto_export", default: false
    t.string "scan_regex"
    t.integer "notification_severity_threshold"
    t.boolean "auto_aggregate", default: true, null: false
    t.index ["client_id", "name"], name: "index_projects_on_client_id_and_name", unique: true
    t.index ["discarded_at"], name: "index_projects_on_discarded_at"
  end

  create_table "projects_suppliers", id: false, force: :cascade do |t|
    t.uuid "project_id", null: false
    t.uuid "supplier_id", null: false
    t.index ["project_id", "supplier_id"], name: "index_projects_suppliers_on_project_id_and_supplier_id", unique: true
  end

  create_table "qualys_configs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "qualys_config_id"
    t.integer "kind", default: 0, null: false
  end

  create_table "qualys_vm_clients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "qualys_id"
    t.string "qualys_name"
    t.uuid "qualys_config_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "qualys_vm_clients_teams", id: false, force: :cascade do |t|
    t.uuid "qualys_vm_client_id", null: false
    t.uuid "team_id", null: false
    t.index ["qualys_vm_client_id", "team_id"], name: "index_qualys_vm_clients_teams", unique: true
  end

  create_table "qualys_wa_clients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "qualys_id"
    t.string "qualys_name"
    t.uuid "qualys_config_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "qualys_wa_clients_teams", id: false, force: :cascade do |t|
    t.uuid "qualys_wa_client_id", null: false
    t.uuid "team_id", null: false
    t.index ["qualys_wa_client_id", "team_id"], name: "index_qualys_wa_clients_teams", unique: true
  end

  create_table "references", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "top_id", null: false
    t.integer "rank", null: false
    t.string "name", null: false
    t.index ["name", "top_id"], name: "references_idx_name_top_id", unique: true
    t.index ["rank", "top_id"], name: "references_idx_rank_top_id", unique: true
  end

  create_table "report_exports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "report_id", null: false
    t.uuid "exporter_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_imports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "report_id", null: false
    t.uuid "import_id", null: false
    t.boolean "auto_aggregate", default: true, null: false
    t.boolean "auto_aggregate_mixing", default: true, null: false
    t.string "scan_name"
  end

  create_table "reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "staff_id", null: false
    t.uuid "project_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level", default: 0
    t.string "title"
    t.date "edited_at", null: false
    t.text "introduction"
    t.text "addendum"
    t.uuid "language_id"
    t.integer "scoring_vm"
    t.integer "scoring_wa"
    t.string "type", default: "ScanReport", null: false
    t.integer "scoring_vm_aggregate", default: 0
    t.integer "scoring_wa_aggregate", default: 0
    t.string "subtitle"
    t.text "aggregates_order_by", default: "---\n- status\n- severity\n- visibility\n- title\n"
    t.index ["discarded_at"], name: "index_reports_on_discarded_at"
    t.index ["project_id", "edited_at"], name: "index_reports_on_project_id_and_edited_at", unique: true
  end

  create_table "reports_contacts", id: false, force: :cascade do |t|
    t.uuid "report_id", null: false
    t.uuid "contact_id", null: false
    t.index ["contact_id", "report_id"], name: "index_reports_contacts_on_contact_id_and_report_id", unique: true
  end

  create_table "reports_targets", id: false, force: :cascade do |t|
    t.uuid "target_id", null: false
    t.uuid "reports_vm_scans_id", null: false
    t.index ["target_id", "reports_vm_scans_id"], name: "index_reports_targets_on_target_id_and_reports_vm_scans_id", unique: true
  end

  create_table "reports_tops", id: false, force: :cascade do |t|
    t.uuid "report_id", null: false
    t.uuid "top_id", null: false
  end

  create_table "reports_vm_scans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "vm_scan_id", null: false
    t.uuid "report_id", null: false
    t.index ["vm_scan_id", "report_id"], name: "index_reports_vm_scans_on_vm_scan_id_and_report_id", unique: true
  end

  create_table "reports_wa_scans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "wa_scan_id", null: false
    t.uuid "report_id", null: false
    t.text "web_app_url"
    t.index ["wa_scan_id", "report_id"], name: "index_reports_wa_scans_on_wa_scan_id_and_report_id", unique: true
  end

  create_table "roles", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority"
    t.uuid "group_id"
    t.boolean "otp_mandatory", default: false, null: false
    t.index ["name", "group_id", "resource_type", "resource_id"], name: "index_roles_on_name_and_grp_id_and_res_type_and_res_id", unique: true
    t.index ["name", "group_id"], name: "index_roles_on_name_and_group_id", unique: true
  end

  create_table "scan_launches", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "scanner", default: 0, null: false
    t.string "scan_type"
    t.uuid "launcher_id", null: false
    t.uuid "report_id"
    t.datetime "launched_at"
    t.datetime "terminated_at"
    t.string "termination_msg"
    t.integer "status", default: 0, null: false
    t.string "target", null: false
    t.string "parameters"
    t.string "kube_scan_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "auto_import", default: true
    t.boolean "auto_aggregate", default: true, null: false
    t.boolean "auto_aggregate_mixing", default: true, null: false
    t.string "scan_name"
    t.uuid "csis_job_id"
  end

  create_table "scan_reports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "scan_report_id"
    t.text "vm_introduction"
    t.text "wa_introduction"
  end

  create_table "sellsy_configs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "encrypted_consumer_token", null: false
    t.string "encrypted_user_token", null: false
    t.string "encrypted_consumer_secret", null: false
    t.string "encrypted_user_secret", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "encrypted_consumer_token_iv", null: false
    t.string "encrypted_user_token_iv", null: false
    t.string "encrypted_consumer_secret_iv", null: false
    t.string "encrypted_user_secret_iv", null: false
  end

  create_table "staffs_teams", id: false, force: :cascade do |t|
    t.uuid "staff_id", null: false
    t.uuid "team_id", null: false
    t.index ["team_id", "staff_id"], name: "index_staffs_teams_on_team_id_and_staff_id", unique: true
  end

  create_table "statistics", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "number_of_scans", default: 0
    t.integer "level_average", default: 0
    t.integer "current_level", default: 0
    t.integer "nof_excellent", default: 0
    t.integer "nof_very_good", default: 0
    t.integer "nof_good", default: 0
    t.integer "nof_satisfactory", default: 0
    t.integer "score", default: 0
    t.uuid "project_id", null: false
    t.datetime "discarded_at"
    t.integer "number_of_reports", default: 0
    t.integer "nof_in_progress", default: 0
    t.integer "blazon", default: 0
    t.integer "number_of_pentests", default: 0
    t.index ["discarded_at"], name: "index_statistics_on_discarded_at"
  end

  create_table "targets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.inet "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "kind", default: "VmTarget", null: false
    t.string "reference_id"
    t.datetime "discarded_at"
    t.string "url"
    t.index ["discarded_at"], name: "index_targets_on_discarded_at"
  end

  create_table "targets_scans", id: false, force: :cascade do |t|
    t.uuid "target_id", null: false
    t.uuid "scan_id", null: false
    t.string "scan_type", null: false
  end

  create_table "teams", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.boolean "otp_mandatory", default: false, null: false
    t.index ["discarded_at"], name: "index_teams_on_discarded_at"
  end

  create_table "teams_projects", id: false, force: :cascade do |t|
    t.uuid "team_id"
    t.uuid "project_id"
    t.datetime "created_at"
    t.index ["team_id", "project_id"], name: "index_teams_projects", unique: true
  end

  create_table "tops", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "notification_email"
    t.string "encrypted_password"
    t.text "public_key"
    t.integer "state", default: 0
    t.uuid "language_id"
    t.string "default_view"
    t.string "ref_identifier"
    t.string "avatar_url"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "type"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "second_factor_attempts_count", default: 0
    t.string "encrypted_otp_secret_key"
    t.string "encrypted_otp_secret_key_iv"
    t.string "encrypted_otp_secret_key_salt"
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at"
    t.datetime "totp_timestamp"
    t.datetime "otp_activated_at"
    t.string "totp_configuration_token"
    t.integer "display_submenu_direction", default: 0
    t.boolean "otp_mandatory", default: false, null: false
    t.text "send_mail_on", default: ["exceeding_severity_threshold"], array: true
    t.text "notify_on", default: ["action_state_update", "comment_creation", "export_generation", "scan_launch_done", "scan_created", "scan_destroyed", "exceeding_severity_threshold"], array: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["encrypted_otp_secret_key"], name: "index_users_on_encrypted_otp_secret_key", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "users_groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "group_id", null: false
    t.string "dashboard_default_card", default: "reports"
    t.index ["group_id", "user_id"], name: "index_users_groups_on_group_id_and_user_id", unique: true
  end

  create_table "users_roles", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "role_id", null: false
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "versions", id: false, force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event"
    t.index ["item_type"], name: "index_versions_item_type"
  end

  create_table "versions_range_records_template", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
  end

  create_table "versions_y2019_m12", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_4de728b"
    t.index ["item_type"], name: "index_versions_item_type_4de728b"
  end

  create_table "versions_y2020_m1", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_872c0e8"
    t.index ["item_type"], name: "index_versions_item_type_872c0e8"
  end

  create_table "versions_y2020_m10", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_5cccf0a"
    t.index ["item_type"], name: "index_versions_item_type_5cccf0a"
  end

  create_table "versions_y2020_m11", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_69f3c28"
    t.index ["item_type"], name: "index_versions_item_type_69f3c28"
  end

  create_table "versions_y2020_m12", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_7c9657e"
    t.index ["item_type"], name: "index_versions_item_type_7c9657e"
  end

  create_table "versions_y2020_m2", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_7486091"
    t.index ["item_type"], name: "index_versions_item_type_7486091"
  end

  create_table "versions_y2020_m3", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_7ff1055"
    t.index ["item_type"], name: "index_versions_item_type_7ff1055"
  end

  create_table "versions_y2020_m4", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_5f6d5e1"
    t.index ["item_type"], name: "index_versions_item_type_5f6d5e1"
  end

  create_table "versions_y2020_m5", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_34a3e75"
    t.index ["item_type"], name: "index_versions_item_type_34a3e75"
  end

  create_table "versions_y2020_m6", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_fb99cdd"
    t.index ["item_type"], name: "index_versions_item_type_fb99cdd"
  end

  create_table "versions_y2020_m7", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_3b5b91f"
    t.index ["item_type"], name: "index_versions_item_type_3b5b91f"
  end

  create_table "versions_y2020_m8", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_eb54edb"
    t.index ["item_type"], name: "index_versions_item_type_eb54edb"
  end

  create_table "versions_y2020_m9", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_60dd7d3"
    t.index ["item_type"], name: "index_versions_item_type_60dd7d3"
  end

  create_table "versions_y2021_m1", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_c7fc514"
    t.index ["item_type"], name: "index_versions_item_type_c7fc514"
  end

  create_table "versions_y2021_m2", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_11d859f"
    t.index ["item_type"], name: "index_versions_item_type_11d859f"
  end

  create_table "versions_y2021_m3", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_3299d5f"
    t.index ["item_type"], name: "index_versions_item_type_3299d5f"
  end

  create_table "versions_y2021_m4", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_3df78b7"
    t.index ["item_type"], name: "index_versions_item_type_3df78b7"
  end

  create_table "versions_y2021_m5", id: :bigint, default: -> { "nextval('versions_range_records_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.uuid "item_id"
    t.index ["event"], name: "index_versions_event_e9a42a4"
    t.index ["item_type"], name: "index_versions_item_type_e9a42a4"
  end

  create_table "vm_occurrences", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "result"
    t.string "netbios"
    t.string "fqdn"
    t.uuid "vulnerability_id"
    t.uuid "scan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "false_positive", default: 0, null: false
    t.inet "ip"
  end

  create_table "vm_scans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "reference"
    t.string "scan_type"
    t.string "status"
    t.string "name"
    t.string "launched_by"
    t.string "option_title"
    t.decimal "processed"
    t.decimal "option_flag"
    t.inet "target"
    t.interval "duration"
    t.datetime "launched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "qualys_vm_client_id"
    t.uuid "account_id"
    t.uuid "import_id"
    t.index ["reference"], name: "index_vm_scans_on_reference", unique: true
  end

  create_table "vulnerabilities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "qid", null: false
    t.text "cve_id", default: [], array: true
    t.string "title", null: false
    t.string "category", null: false
    t.string "bugtraqs", array: true
    t.string "cvss"
    t.datetime "modified", null: false
    t.datetime "published", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "solution"
    t.text "diagnosis"
    t.string "internal_type"
    t.integer "severity"
    t.integer "patchable"
    t.text "consequence"
    t.integer "pci_flag"
    t.integer "remote"
    t.text "additional_info"
    t.string "cvss_vector"
    t.string "kb_type"
    t.integer "kind"
    t.uuid "import_id"
    t.string "cvss_version", default: "3"
    t.string "exploitability_score"
    t.string "impact_score"
    t.string "osvdb"
    t.index ["kb_type", "qid"], name: "index_vulnerabilities_on_qid_and_kb_type", unique: true
  end

  create_table "wa_occurrences", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "result"
    t.string "uri"
    t.uuid "vulnerability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "scan_id"
    t.string "param"
    t.string "content"
    t.integer "false_positive", default: 0, null: false
    t.text "payload"
    t.text "data"
  end

  create_table "wa_scans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "internal_id"
    t.string "name"
    t.string "reference"
    t.string "scan_type"
    t.string "mode"
    t.string "multi"
    t.string "scanner_appliance_type"
    t.string "cancel_option"
    t.integer "profile_id"
    t.string "profile_name"
    t.string "launched_by"
    t.string "status"
    t.string "links_crawled"
    t.decimal "nb_requests"
    t.string "results_status"
    t.string "auth_status"
    t.string "os"
    t.interval "crawl_duration"
    t.interval "test_duration"
    t.datetime "launched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "qualys_wa_client_id"
    t.uuid "account_id"
    t.uuid "import_id"
    t.index ["launched_by"], name: "index_wa_scans_on_launched_by"
    t.index ["reference"], name: "index_wa_scans_on_reference", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "aggregates", "reports", on_delete: :nullify
  add_foreign_key "aggregates_vm_occurrences", "aggregates", on_delete: :cascade
  add_foreign_key "aggregates_vm_occurrences", "vm_occurrences", on_delete: :cascade
  add_foreign_key "aggregates_wa_occurrences", "aggregates", on_delete: :cascade
  add_foreign_key "aggregates_wa_occurrences", "wa_occurrences", on_delete: :cascade
  add_foreign_key "certificates", "projects", on_delete: :nullify
  add_foreign_key "certificates_languages", "certificates", on_delete: :cascade
  add_foreign_key "certificates_languages", "languages", on_delete: :cascade
  add_foreign_key "clients_contacts", "clients", on_delete: :cascade
  add_foreign_key "clients_contacts", "users", column: "contact_id", on_delete: :cascade
  add_foreign_key "clients_suppliers", "clients", column: "supplier_id", on_delete: :cascade
  add_foreign_key "clients_suppliers", "clients", on_delete: :cascade
  add_foreign_key "comments", "actions", on_delete: :cascade
  add_foreign_key "dependencies", "actions", column: "predecessor_id", on_delete: :nullify
  add_foreign_key "dependencies", "actions", column: "successor_id", on_delete: :nullify
  add_foreign_key "exploits", "exploit_sources", on_delete: :cascade
  add_foreign_key "exploits_vulnerabilities", "exploits", on_delete: :cascade
  add_foreign_key "exploits_vulnerabilities", "vulnerabilities", on_delete: :cascade
  add_foreign_key "imports", "accounts", on_delete: :nullify
  add_foreign_key "imports", "scan_launches", on_delete: :nullify
  add_foreign_key "projects", "clients", on_delete: :cascade
  add_foreign_key "projects_suppliers", "clients", column: "supplier_id", on_delete: :cascade
  add_foreign_key "projects_suppliers", "projects", on_delete: :cascade
  add_foreign_key "report_exports", "reports", on_delete: :cascade
  add_foreign_key "report_exports", "users", column: "exporter_id", on_delete: :restrict
  add_foreign_key "reports", "projects", on_delete: :nullify
  add_foreign_key "reports", "users", column: "staff_id", on_delete: :cascade
  add_foreign_key "reports_contacts", "reports", on_delete: :cascade
  add_foreign_key "reports_contacts", "users", column: "contact_id", on_delete: :cascade
  add_foreign_key "reports_targets", "reports_vm_scans", column: "reports_vm_scans_id", on_delete: :cascade
  add_foreign_key "reports_targets", "targets", on_delete: :cascade
  add_foreign_key "reports_vm_scans", "reports", on_delete: :cascade
  add_foreign_key "reports_vm_scans", "vm_scans", on_delete: :cascade
  add_foreign_key "reports_wa_scans", "reports", on_delete: :cascade
  add_foreign_key "reports_wa_scans", "wa_scans", on_delete: :cascade
  add_foreign_key "roles", "groups", on_delete: :nullify
  add_foreign_key "scan_launches", "jobs", column: "csis_job_id", on_delete: :nullify
  add_foreign_key "staffs_teams", "teams", on_delete: :cascade
  add_foreign_key "staffs_teams", "users", column: "staff_id", on_delete: :cascade
  add_foreign_key "statistics", "projects", on_delete: :nullify
  add_foreign_key "users_groups", "groups", on_delete: :cascade
  add_foreign_key "users_groups", "users", on_delete: :cascade
  add_foreign_key "users_roles", "roles", on_delete: :cascade
  add_foreign_key "users_roles", "users", on_delete: :cascade
  add_foreign_key "vm_occurrences", "vm_scans", column: "scan_id", on_delete: :nullify
  add_foreign_key "vm_occurrences", "vulnerabilities", on_delete: :cascade
  add_foreign_key "wa_occurrences", "vulnerabilities", on_delete: :cascade
  add_foreign_key "wa_occurrences", "wa_scans", column: "scan_id", on_delete: :nullify
end
