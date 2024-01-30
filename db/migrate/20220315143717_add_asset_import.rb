class AddAssetImport < ActiveRecord::Migration[6.1]
  def change
    # Add import_id to asset
    add_column :assets, :import_id, :uuid
  end
end
