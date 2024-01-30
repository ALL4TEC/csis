class AddOptionalAccountToImports < ActiveRecord::Migration[6.1]
  def change
    add_column :imports, :account_id, :uuid
    add_foreign_key :imports, :accounts, column: :account_id, primary_key: :id, on_delete: :nullify
    change_column :imports, :importer_id, :uuid, null: true
  end
end
