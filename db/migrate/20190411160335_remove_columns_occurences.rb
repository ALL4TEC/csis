class RemoveColumnsOccurences < ActiveRecord::Migration[5.2]
  def change
    remove_column :wa_occurences, :aggregate_id
    remove_column :vm_occurences, :aggregate_id
  end
end
