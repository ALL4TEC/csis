class FixContactImportation < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :main_contact_id
    
    create_table :clients_contacts, id: false do |t|
      t.uuid :client_id, null: false
      t.uuid :contact_id, null: false
    end

    add_foreign_key :clients_contacts, :clients, column: :client_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :clients_contacts, :contacts, column: :contact_id, primary_key: :id, on_delete: :cascade
    add_index :clients_contacts, [:contact_id, :client_id], unique: true

    create_table :reports_contacts, id: false do |t|
      t.uuid :report_id, null: false
      t.uuid :contact_id, null: false
    end

    add_foreign_key :reports_contacts, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :reports_contacts, :contacts, column: :contact_id, primary_key: :id, on_delete: :cascade
    add_index :reports_contacts, [:contact_id, :report_id], unique: true
  end
end
