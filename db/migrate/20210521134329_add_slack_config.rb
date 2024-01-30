class AddSlackConfig < ActiveRecord::Migration[6.1]
  def change
    create_table :slack_configs, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :slack_config_id, null: false
      t.string :channel_id
      t.string :bot_user_id
    end

    create_table "accounts_users", id: :uuid, force: :cascade do |t|
      t.uuid "account_id", null: false
      t.uuid "user_id", null: false
      t.string "channel_id"
      t.text :notify_on, default: ["action_state_update", "comment_creation", "export_generation", "scan_launch_done", "scan_created", "scan_destroyed", "exceeding_severity_threshold"], array: true
      t.index ["account_id", "user_id"], name: "index_accounts_users", unique: true
    end

    add_column :accounts, :creator_id, :uuid
    change_column_null :accounts, :url, true
  end
end
