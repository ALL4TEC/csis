class RenameCommonVmAndWaFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :vm_scans, :state, :status
    rename_column :vm_scans, :title, :name
    rename_column :vm_scans, :launched, :launched_at
    rename_column :vm_scans, :user_login, :launched_by
    rename_column :wa_scans, :launched, :launched_at
    rename_column :wa_scans, :launched_by_username, :launched_by
  end
end
