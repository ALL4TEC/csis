class AddFieldBlazonToStatistics < ActiveRecord::Migration[5.2]
  def change
    add_column :statistics, :blazon, :integer, default: 0
  end
end
