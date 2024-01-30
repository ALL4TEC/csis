class CertificateCreation < ActiveRecord::Migration[5.2]
  def change
    create_table :certificates, id: :uuid, default: 'uuid_generate_v4()'do |t|
      t.string :path, default: ''
      t.string :sync_link, default: ''
      t.integer :stars_level, default: 0
      t.integer :transparency_level, default: 2
      t.integer :follow_type, default: 1
      t.uuid :project_id, null: false
    end
    add_foreign_key :certificates, :projects, column: :project_id, primary_key: :id, on_delete: :nullify
  end
end
