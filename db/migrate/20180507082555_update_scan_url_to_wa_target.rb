class UpdateScanUrlToWaTarget < ActiveRecord::Migration[5.2]
  def change
    rename_table :scan_urls, :wa_targets
    drop_table :scan_ips_scan_urls
  end
end
