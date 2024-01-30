class ScanIpsScanUrlsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :scan_ips_scan_urls, id: false do |t|
      t.uuid :scan_ip_id, null: false
      t.uuid :scan_url_id, null: false
    end
    add_foreign_key :scan_ips_scan_urls, :scan_ips, column: :scan_ip_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :scan_ips_scan_urls, :scan_urls, column: :scan_url_id, primary_key: :id, on_delete: :cascade

    add_index :scan_ips_scan_urls, [:scan_ip_id, :scan_url_id], unique: true
  end
end
