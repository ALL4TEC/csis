class CreateScans < ActiveRecord::Migration[5.2]
  def change
    create_table :scans, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :reference
      t.string :scan_type
      t.string :state
      t.string :title
      t.string :user_login
      t.string :option_title
      t.decimal :processed
      t.decimal :option_flag
      t.uuid :project_id      
      t.inet :target
      
      t.interval :duration
      t.datetime :launched
      t.timestamps
    end
    add_foreign_key :scans, :projects, column: :project_id, primary_key: :id, on_delete: :nullify
    add_index :scans, :reference, unique: true 
  end
end
