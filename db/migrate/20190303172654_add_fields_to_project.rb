class AddFieldsToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :folder_name, :string, default: ''
  end
end
