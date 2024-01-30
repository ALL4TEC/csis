class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :staff_id, null: false
      t.uuid :project_id, null: false
      t.datetime :discarded_at
      
      t.timestamps
    end
    add_index :reports, :discarded_at
    add_foreign_key :reports, :staff, column: :staff_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :reports, :projects, column: :project_id, primary_key: :id, on_delete: :nullify
    add_foreign_key :scans, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
  end
end
