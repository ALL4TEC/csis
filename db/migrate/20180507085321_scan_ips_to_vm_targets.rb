class ScanIpsToVmTargets < ActiveRecord::Migration[5.2]
  def change
    rename_table :scan_ips, :vm_targets
    # rename_column :vulnerability_statuses, :scan_ip_id, :vm_target_id
  end
end
