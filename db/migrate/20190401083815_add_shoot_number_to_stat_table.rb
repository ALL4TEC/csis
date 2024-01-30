class AddShootNumberToStatTable < ActiveRecord::Migration[5.2]
  def change
    add_column :statistics, :numberOfReport, :integer, default: 0
  end
end
