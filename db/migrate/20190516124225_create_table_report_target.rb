class CreateTableReportTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :reports_vm_scans, :id, :primary_key
    add_column :reports_vm_scans, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :reports_vm_scans do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE reports_vm_scans ADD PRIMARY KEY (id);"

    create_table :reports_targets, id: false do |t|
      t.uuid :target_id, null: false
      t.uuid :reports_vm_scans_id, null: false
    end
    add_foreign_key :reports_targets, :vm_targets, column: :target_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :reports_targets, :reports_vm_scans, column: :reports_vm_scans_id, primary_key: :id, on_delete: :cascade
    add_index :reports_targets, [:target_id, :reports_vm_scans_id], unique: true
  end
end
