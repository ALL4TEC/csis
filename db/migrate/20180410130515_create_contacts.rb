class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :internal_id, readonly: true 
      t.string :full_name
      t.string :email, null: false

      t.timestamps
    end

    add_index :contacts, :internal_id, unique: true 
    add_column :clients, :main_contact_id, :integer
    add_foreign_key :clients, :contacts, column: :main_contact_id, primary_key: :internal_id, on_delete: :nullify
  end
end
