class CreateReportExports < ActiveRecord::Migration[5.2]
  def change
    create_table :report_exports, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :report_id, null: false
      t.uuid :exporter_id, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :report_exports, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :report_exports, :staff, column: :exporter_id, primary_key: :id, on_delete: :restrict
  end
end
