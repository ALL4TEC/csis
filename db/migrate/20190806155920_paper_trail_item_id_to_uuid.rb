class PaperTrailItemIdToUuid < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :item_uid, :uuid
  end
end
