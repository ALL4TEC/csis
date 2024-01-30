class UpdateScansWithIpsUrls < ActiveRecord::Migration[5.2]
  def change
    add_column :scans, :kind, :integer, default: 0
    add_column :scans, :report_id, :uuid
    add_foreign_key :scan_ips, :scans, column: :scan_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :scan_urls, :scans, column: :scan_id, primary_key: :id, on_delete: :cascade
  end
end
