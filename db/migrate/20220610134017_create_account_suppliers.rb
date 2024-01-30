class CreateAccountSuppliers < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts_suppliers, id: false do |t|
      t.uuid 'account_id', nil: false
      t.uuid 'supplier_id', nil: false

      t.timestamps
    end
    add_foreign_key :accounts_suppliers, :accounts, column: :account_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :accounts_suppliers, :clients, column: :supplier_id, primary_key: :id, on_delete: :cascade
  end
end
