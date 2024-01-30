class RenameScansQualysClientsToId < ActiveRecord::Migration[5.2]
  def change
    rename_column :wa_scans, :qualys_wa_client, :qualys_wa_client_id
    rename_column :vm_scans, :qualys_vm_client, :qualys_vm_client_id
  end
end
