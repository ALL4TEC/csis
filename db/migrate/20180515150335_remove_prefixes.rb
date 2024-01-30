class RemovePrefixes < ActiveRecord::Migration[5.2]
  def change
    rename_column :wa_occurences, :wa_scan_id, :scan_id
    rename_column :vm_occurences, :vm_target_id, :target_id
    rename_column :vm_targets, :vm_scan_id, :scan_id
  end
end
