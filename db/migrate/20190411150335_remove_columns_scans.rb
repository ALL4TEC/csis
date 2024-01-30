class RemoveColumnsScans < ActiveRecord::Migration[5.2]
  def change
    remove_column :wa_scans, :project_id
    remove_column :wa_scans, :report_id
    remove_column :vm_scans, :project_id
    remove_column :vm_scans, :report_id
  end
end
