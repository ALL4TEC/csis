class AddField < ActiveRecord::Migration[5.2]
  def change
    add_column :statistics, :nofInProgress, :integer, default: 0
  end
end
