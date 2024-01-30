class FalsePositiveAndHiddenAggregates < ActiveRecord::Migration[5.2]
  def change
      add_column :aggregates, :hidden, :integer, default: 0, null: false
      add_column :vm_occurences, :false_positive, :integer, default: 0, null: false
      add_column :wa_occurences, :false_positive, :integer, default: 0, null: false
  end
end
