class RolifyCreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name
      t.integer :group, default: 0, null: false
      t.uuid :resource_id
      t.string :resource_type

      t.timestamps
    end

    create_table(:staff_roles, :id => false) do |t|
      t.uuid :staff_id, null: false
      t.uuid :role_id, null: false
    end

    add_foreign_key :staff_roles, :staff, column: :staff_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :staff_roles, :roles, column: :role_id, primary_key: :id, on_delete: :cascade
    
    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:staff_roles, [ :staff_id, :role_id ])
  end
end
