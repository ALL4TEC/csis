class ChangeHiddenToVisibility < ActiveRecord::Migration[5.2]
  def change
    rename_column :aggregates, :hidden, :visibility
  end
end
