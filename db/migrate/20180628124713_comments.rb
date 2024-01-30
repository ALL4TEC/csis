class Comments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments, id: :uuid, default: 'uuid_generate_v4()'do |t|
      t.uuid :action_id
      t.text :comment
      t.text :author

      t.timestamps
    end
    add_foreign_key :comments, :actions, column: :action_id, primary_key: :id, on_delete: :cascade
    add_column :comments, :discarded_at, :datetime
    add_index :comments, :discarded_at
  end
end
