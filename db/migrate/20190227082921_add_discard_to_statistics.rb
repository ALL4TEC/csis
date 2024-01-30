class AddDiscardToStatistics < ActiveRecord::Migration[5.2]
  def up
    add_column :statistics, :discarded_at, :datetime
    add_index :statistics, :discarded_at
  end
end
