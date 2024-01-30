class AddStaffAndContactDefaultView < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :default_view, :string, default: 'reports'
    add_column :contacts, :default_view, :string, default: 'reports'
  end
end
