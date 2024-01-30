class AddClientToScan < ActiveRecord::Migration[5.2]
  def change
    add_column :wa_scans, :qualys_wa_client, :uuid
    add_column :vm_scans, :qualys_vm_client, :uuid
  end

  create_table :qualys_wa_clients, id: :uuid, default: 'uuid_generate_v4()' do |t|
    t.string :qualys_id
    t.string :qualys_name
    t.uuid :team_id
    t.uuid :qualys_config_id
    t.timestamps
  end

  create_table :qualys_vm_clients, id: :uuid, default: 'uuid_generate_v4()' do |t|
    t.string :qualys_id
    t.string :qualys_name
    t.uuid :team_id
    t.uuid :qualys_config_id
    t.timestamps
  end
end
