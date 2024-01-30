class CreateOverrides < ActiveRecord::Migration[5.2]
  def change
    create_table :overrides, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :status
      t.uuid :vulnerability_id
      t.uuid :project_id

      t.timestamps
    end
    add_foreign_key :overrides, :vulnerabilities, column: :vulnerability_id, primary_key: :id, on_delete: :nullify
    add_foreign_key :overrides, :projects, column: :project_id, primary_key: :id, on_delete: :nullify
  end
end
