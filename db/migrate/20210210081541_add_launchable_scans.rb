class AddLaunchableScans < ActiveRecord::Migration[6.1]
  def change
    create_table :scan_launches, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :scanner, default: 0, null: false
      t.string :scan_type
      t.uuid :launcher_id, null: false
      t.uuid :report_id
      t.datetime :launched_at
      t.datetime :terminated_at
      t.string :termination_msg
      t.integer :status, default: 0, null: false
      t.string :target, null: false
      t.string :parameters # TODO: or json ?
      t.string :kube_scan_id

      t.timestamps
    end

    add_column :imports, :scan_launch_id, :uuid
    add_foreign_key :imports, :scan_launches, column: :scan_launch_id, primary_key: :id, on_delete: :nullify
  end
end
