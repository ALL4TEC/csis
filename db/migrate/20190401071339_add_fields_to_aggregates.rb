class AddFieldsToAggregates < ActiveRecord::Migration[5.2]
  def change
      add_column :aggregates, :scope, :text
  end
end
