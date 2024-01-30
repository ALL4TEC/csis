class Actions < ActiveRecord::Migration[5.2]
  def change
    create_table :actions, id: :uuid, default: 'uuid_generate_v4()'do |t|
      t.uuid :aggregate_id, null: false
      t.integer :state, null: false
      t.integer :meta_state, null: false
      t.text :name, null: false
      t.text :description
      t.uuid :receiver_id
      t.uuid :author_id, null: false

      t.timestamps
    end
    add_foreign_key :actions, :aggregates, column: :aggregate_id, primary_key: :id, on_delete: :nullify
    add_column :actions, :discarded_at, :datetime
    add_index :actions, :discarded_at
  end
end
