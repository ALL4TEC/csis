class AddExportingToReport < ActiveRecord::Migration[5.2]
  def change
  	add_column :reports, :exporting, :boolean, null: false, default: false
  end
end
