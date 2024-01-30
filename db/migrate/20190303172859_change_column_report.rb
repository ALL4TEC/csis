class ChangeColumnReport < ActiveRecord::Migration[5.2]
  def change
    change_column :reports, :score, :integer, default: 0
  end
end
