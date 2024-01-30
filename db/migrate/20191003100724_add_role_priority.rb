class AddRolePriority < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :priority, :integer
  end
end
