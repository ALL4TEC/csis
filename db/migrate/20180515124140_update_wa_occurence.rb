class UpdateWaOccurence < ActiveRecord::Migration[5.2]
  def change
    add_column :wa_occurences, :param, :string
    add_column :wa_occurences, :content, :string
  end
end
