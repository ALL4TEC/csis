class AddContactsRoles < ActiveRecord::Migration[5.2]
  def change
    create_table(:contacts_roles, :id => false) do |t|
      t.uuid :contact_id, null: false
      t.uuid :role_id, null: false
    end

    add_foreign_key :contacts_roles, :contacts, column: :contact_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :contacts_roles, :roles, column: :role_id, primary_key: :id, on_delete: :cascade
    
    add_index(:contacts_roles, [ :contact_id, :role_id ])
  end
end
