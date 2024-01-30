class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :status
      t.uuid :vulnerability_id
      t.uuid :report_id

      t.timestamps
    end
    add_foreign_key :histories, :vulnerabilities, column: :vulnerability_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :histories, :reports, column: :report_id, primary_key: :id, on_delete: :cascade
  end
end
