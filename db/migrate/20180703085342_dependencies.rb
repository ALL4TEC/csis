class Dependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :dependencies, id: :uuid, default: 'uuid_generate_v4()'do |t|
      t.uuid :predecessor_id, null: false
      t.uuid :successor_id, null: false

      t.timestamps
    end
    add_foreign_key :dependencies, :actions, column: :predecessor_id, primary_key: :id, on_delete: :nullify
    add_foreign_key :dependencies, :actions, column: :successor_id, primary_key: :id, on_delete: :nullify
    add_column :dependencies, :discarded_at, :datetime
    add_index :dependencies, :discarded_at
  end
end
