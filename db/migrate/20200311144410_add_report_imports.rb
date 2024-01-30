class AddReportImports < ActiveRecord::Migration[6.0]
  def change
    create_table "imports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "importer_id", null: false
      t.integer "status", default: 0, null: false
      t.string "type", null: false
      t.integer "import_type", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "report_imports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "report_id", null: false
      t.uuid "import_id", null: false
    end
    add_column :wa_scans, :import_id, :uuid
    add_column :vm_scans, :import_id, :uuid
  end
end
