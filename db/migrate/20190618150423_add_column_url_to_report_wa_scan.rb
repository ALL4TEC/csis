class AddColumnUrlToReportWaScan < ActiveRecord::Migration[5.2]
  def change
    add_column :reports_wa_scans, :id, :primary_key
    add_column :reports_wa_scans, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :reports_wa_scans do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE reports_wa_scans ADD PRIMARY KEY (id);"

    add_column :reports_wa_scans, :web_app_url, :text
  end
end
