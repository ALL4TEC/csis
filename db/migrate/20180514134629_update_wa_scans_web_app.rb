class UpdateWaScansWebApp < ActiveRecord::Migration[5.2]
  def change
    remove_column :wa_occurences, :wa_target_id
    drop_table :wa_targets
    add_column :wa_occurences, :wa_scan_id, :uuid
    add_foreign_key :wa_occurences, :wa_scans, column: :wa_scan_id, primary_key: :id, on_delete: :nullify
  end
end
