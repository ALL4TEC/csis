class AddFieldsToReports < ActiveRecord::Migration[5.2]
  def change
      add_column :reports, :notes, :text
      add_column :reports, :vm_introduction, :text
      add_column :reports, :wa_introduction, :text
  end
end
