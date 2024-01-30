class AddDefaultToEditedAt < ActiveRecord::Migration[5.2]
  def change
    change_column :reports, :edited_at, :date, null: false
  end
end
