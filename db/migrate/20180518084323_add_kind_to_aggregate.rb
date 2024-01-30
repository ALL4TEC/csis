class AddKindToAggregate < ActiveRecord::Migration[5.2]
  def change
    add_column :aggregates, :kind, :int, null: false, default: 1
  end
end
