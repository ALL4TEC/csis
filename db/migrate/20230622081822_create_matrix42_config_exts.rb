class CreateMatrix42ConfigExts < ActiveRecord::Migration[7.0]
  def change
    create_table :matrix42_configs, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :matrix42_config_id, null: false
      t.integer :status, null: false
      t.integer :default_ticket_type, null: false
      t.datetime :need_refresh_at
      t.string :api_url, null: false

      t.timestamps
    end
  end
end
