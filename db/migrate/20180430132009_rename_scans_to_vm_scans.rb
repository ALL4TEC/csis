class RenameScansToVmScans < ActiveRecord::Migration[5.2]
  def change
    rename_table :scans, :vm_scans
    remove_column :scan_ips, :scan_id
    remove_column :scan_urls, :scan_id
  end
end
