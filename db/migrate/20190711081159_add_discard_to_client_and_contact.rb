class AddDiscardToClientAndContact < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :discarded_at, :datetime
    add_index :clients, :discarded_at

    add_column :contacts, :discarded_at, :datetime
    add_index :contacts, :discarded_at
  end
end
