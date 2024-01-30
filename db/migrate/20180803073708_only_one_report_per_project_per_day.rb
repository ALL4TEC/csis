class OnlyOneReportPerProjectPerDay < ActiveRecord::Migration[5.2]
  def change
  	add_index :reports, [:project_id, :edited_at], unique: true
  end
end
