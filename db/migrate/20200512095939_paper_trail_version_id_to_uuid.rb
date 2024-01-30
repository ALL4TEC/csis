class PaperTrailVersionIdToUuid < ActiveRecord::Migration[6.0]
  def change
    remove_column :versions, :item_id
    rename_column :versions, :item_uid, :item_id
  end
end
