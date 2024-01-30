class UpdateContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :public_key, :text
    add_column :contacts, :password_digest, :string
  end
end
