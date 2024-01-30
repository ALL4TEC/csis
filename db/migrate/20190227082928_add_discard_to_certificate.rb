class AddDiscardToCertificate < ActiveRecord::Migration[5.2]
  def up
    add_column :certificates, :discarded_at, :datetime
    add_index :certificates, :discarded_at
  end
end
