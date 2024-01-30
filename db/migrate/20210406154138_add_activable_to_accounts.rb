class AddActivableToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :discarded_at, :datetime
    add_index :accounts, :discarded_at
  end
end
