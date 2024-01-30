class AddFieldDataToWaOccurence < ActiveRecord::Migration[5.2]
  def change
    add_column :wa_occurences, :data, :text
  end
end
