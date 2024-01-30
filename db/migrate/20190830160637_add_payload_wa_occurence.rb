class AddPayloadWaOccurence < ActiveRecord::Migration[5.2]
  def change
    add_column :wa_occurences, :payload, :text
  end
end
