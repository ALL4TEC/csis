class AddUniqueRolesIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :staffs_roles, name: "index_staffs_roles_on_staff_id_and_role_id"
    add_index :staffs_roles, ["staff_id", "role_id"], name: "index_staffs_roles_on_staff_id_and_role_id", unique: true
    remove_index :contacts_roles, name: "index_contacts_roles_on_contact_id_and_role_id"
    add_index :contacts_roles, ["contact_id", "role_id"], name: "index_contacts_roles_on_contact_id_and_role_id", unique: true
  end
end
