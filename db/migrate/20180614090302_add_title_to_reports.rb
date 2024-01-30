class AddTitleToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :title, :string
    add_column :reports, :edited_at, :date
  end
end
