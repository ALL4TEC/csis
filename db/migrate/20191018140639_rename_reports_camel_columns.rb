class RenameReportsCamelColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :statistics, :numberOfScans, :number_of_scans
    rename_column :statistics, :levelAverage, :level_average
    rename_column :statistics, :currentLevel, :current_level
    rename_column :statistics, :numberOfReport, :number_of_reports
  end
end
