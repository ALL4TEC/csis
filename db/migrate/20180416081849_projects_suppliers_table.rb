class ProjectsSuppliersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :projects_suppliers, id: false do |t|
      t.uuid :project_id, null: false
      t.uuid :supplier_id, null: false
    end
    add_foreign_key :projects_suppliers, :projects, column: :project_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :projects_suppliers, :clients, column: :supplier_id, primary_key: :id, on_delete: :cascade

    add_index :projects_suppliers, [:project_id, :supplier_id], unique: true
  end
end
