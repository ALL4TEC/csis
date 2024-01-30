class AddNotificationsDiscard < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :discarded_at, :datetime
    add_index :notifications, :discarded_at
  end
end
