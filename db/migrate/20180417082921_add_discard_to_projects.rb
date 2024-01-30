class AddDiscardToProjects < ActiveRecord::Migration[5.2]
  def up
    add_column :projects, :discarded_at, :datetime
    add_index :projects, :discarded_at
  end
end
