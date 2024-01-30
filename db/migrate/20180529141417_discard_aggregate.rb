class DiscardAggregate < ActiveRecord::Migration[5.2]
  def change
    add_column :aggregates, :discarded_at, :datetime
    add_index :aggregates, :discarded_at
  end
end
