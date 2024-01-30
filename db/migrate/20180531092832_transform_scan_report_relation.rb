class TransformScanReportRelation < ActiveRecord::Migration[5.2]
  def change
    create_table :reports_vm_scans, id: false do |t|
      t.uuid :vm_scan_id, null: false
      t.uuid :report_id, null: false
    end
    create_table :reports_wa_scans, id: false do |t|
      t.uuid :wa_scan_id, null: false
      t.uuid :report_id, null: false
    end
    add_foreign_key :reports_vm_scans, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :reports_vm_scans, :vm_scans, column: :vm_scan_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :reports_wa_scans, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :reports_wa_scans, :wa_scans, column: :wa_scan_id, primary_key: :id, on_delete: :cascade
    add_index :reports_vm_scans, [:vm_scan_id, :report_id], unique: true
    add_index :reports_wa_scans, [:wa_scan_id, :report_id], unique: true
  end
end
