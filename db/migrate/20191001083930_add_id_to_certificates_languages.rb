class AddIdToCertificatesLanguages < ActiveRecord::Migration[5.2]
  def change
    add_column :certificates_languages, :id, :primary_key
    add_column :certificates_languages, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :certificates_languages do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE certificates_languages ADD PRIMARY KEY (id);"
  end
end
