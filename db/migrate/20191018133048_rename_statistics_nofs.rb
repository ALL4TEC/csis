class RenameStatisticsNofs < ActiveRecord::Migration[5.2]
  def change
    rename_column :statistics, :nofExcellent, :nof_excellent
    rename_column :statistics, :nofVeryGood, :nof_very_good
    rename_column :statistics, :nofGood, :nof_good
    rename_column :statistics, :nofOk, :nof_satisfactory
    rename_column :statistics, :nofInProgress, :nof_in_progress
  end
end
