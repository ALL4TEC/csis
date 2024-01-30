class CreateServicenowConfigExts < ActiveRecord::Migration[6.1]
  def change
    create_table :servicenow_configs, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :servicenow_config_id, null: false
      t.integer :status, null: false
      t.datetime :need_refresh_at
      t.string :fixed_vuln, null: false
      t.string :accepted_risk, null: false

      t.timestamps
    end
  end
end
