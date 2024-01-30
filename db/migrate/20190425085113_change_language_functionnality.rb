class ChangeLanguageFunctionnality < ActiveRecord::Migration[5.2]
  def change
    remove_column :contacts, :language
    remove_column :staff, :language
    remove_column :reports, :language
    remove_column :projects, :language

    add_column :contacts, :language_id, :uuid
    add_column :staff, :language_id, :uuid
    add_column :reports, :language_id, :uuid
    add_column :projects, :language_id, :uuid

    create_table :languages, id: :uuid, default: 'uuid_generate_v4()'do |t|
      t.string :name, null: false
      t.string :iso, null: false
    end

    create_table :certificates_languages, id: false do |t|
      t.uuid :language_id, null: false
      t.uuid :certificate_id, null: false
      t.string :sync_link
    end

    add_foreign_key :certificates_languages, :languages, column: :language_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :certificates_languages, :certificates, column: :certificate_id, primary_key: :id, on_delete: :cascade
    add_index :certificates_languages, [:certificate_id, :language_id], unique: true
  end
end
