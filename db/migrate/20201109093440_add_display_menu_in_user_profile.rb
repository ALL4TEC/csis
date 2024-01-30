class AddDisplayMenuInUserProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :display_submenu_direction, :integer, default: 0
  end
end
