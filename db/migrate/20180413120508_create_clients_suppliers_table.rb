class CreateClientsSuppliersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :clients_suppliers, id: false do |t|
      t.uuid :client_id, null: false
      t.uuid :supplier_id, null: false
    end
    add_foreign_key :clients_suppliers, :clients, column: :client_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :clients_suppliers, :clients, column: :supplier_id, primary_key: :id, on_delete: :cascade
  end
end
