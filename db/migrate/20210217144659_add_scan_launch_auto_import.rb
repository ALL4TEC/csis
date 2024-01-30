class AddScanLaunchAutoImport < ActiveRecord::Migration[6.1]
  def change
    add_column :scan_launches, :auto_import, :boolean, default: true
  end
end
