class AutoGenerateAggregates < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :auto_aggregate, :boolean, null: false, default: true
  end
end
