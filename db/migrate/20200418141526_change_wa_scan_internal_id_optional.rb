class ChangeWaScanInternalIdOptional < ActiveRecord::Migration[6.0]
  def change
    change_column :wa_scans, :internal_id, :string, null: true
  end
end
