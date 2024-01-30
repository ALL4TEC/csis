class AddScanNameToReportImportAndScanLaunch < ActiveRecord::Migration[6.1]
  def change
    add_column :report_imports, :scan_name, :string
    add_column :scan_launches, :scan_name, :string
  end
end
