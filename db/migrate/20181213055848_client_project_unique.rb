class ClientProjectUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :projects, [:client_id, :name], unique: true
  end
end
