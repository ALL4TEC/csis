class AddScoringToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :scoring_vm, :integer
    add_column :reports, :scoring_was, :integer
  end
end
