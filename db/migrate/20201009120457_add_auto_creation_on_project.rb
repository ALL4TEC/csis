class AddAutoCreationOnProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :auto_generate, :boolean, default: false
    add_column :projects, :auto_export, :boolean, default: false
    add_column :projects, :scan_regex, :string
    add_column :projects, :schedule, :string
  end
end
