class ReportUpdateScoreColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :score, :integer
  end
end
