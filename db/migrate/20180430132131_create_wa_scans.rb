class CreateWaScans < ActiveRecord::Migration[5.2]
  def change
    create_table :wa_scans, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :internal_id, nil: false
      t.string :name, nil: false
      t.string :reference, nil: false
      t.string :scan_type, nil: false
      t.string :mode
      t.string :multi
      t.integer :web_app_id
      t.string :web_app_name
      t.string :web_app_url
      t.string :scanner_appliance_type
      t.string :cancel_option
      t.integer :profile_id
      t.string :profile_name
      t.string :launched_by_username
      t.string :status
      t.string :links_crawled
      t.decimal :nb_requests
      t.string :results_status
      t.string :auth_status
      t.string :os
      t.uuid :project_id
      t.uuid :report_id
      
      t.interval :crawl_duration
      t.interval :test_duration
      t.datetime :launched
      t.timestamps
    end
    add_index :wa_scans, :launched_by_username
    add_column :scan_urls, :wa_scan_id, :uuid
    add_column :scan_ips, :vm_scan_id, :uuid
    add_column :scan_urls, :vm_scan_id, :uuid
    add_column :vulnerability_statuses, :data, :string
    add_column :vulnerability_statuses, :title, :string
    remove_column :vm_scans, :kind
    add_foreign_key :scan_urls, :wa_scans, column: :wa_scan_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :scan_ips, :vm_scans, column: :vm_scan_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :scan_urls, :vm_scans, column: :vm_scan_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :wa_scans, :projects, column: :project_id, primary_key: :id, on_delete: :nullify
    add_foreign_key :wa_scans, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
    add_index :wa_scans, :reference, unique: true 
  end
end
