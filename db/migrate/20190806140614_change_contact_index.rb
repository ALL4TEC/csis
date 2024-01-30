class ChangeContactIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :contacts, :internal_id
    remove_index :clients, :internal_id

    add_index :contacts, :email, unique: true
    add_index :clients, :name, unique: true
  end
end
