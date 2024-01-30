class ModifyScoreToLevelReports < ActiveRecord::Migration[5.2]
  def change
    rename_column :reports, :score, :level
  end
end
