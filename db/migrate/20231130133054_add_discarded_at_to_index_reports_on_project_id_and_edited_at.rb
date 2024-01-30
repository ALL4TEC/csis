class AddDiscardedAtToIndexReportsOnProjectIdAndEditedAt < ActiveRecord::Migration[7.0]
  def change
    remove_index :reports, [:project_id, :edited_at]
    add_index :reports, [:project_id, :edited_at, :discarded_at], unique: true
  end
end
