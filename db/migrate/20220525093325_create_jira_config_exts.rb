class CreateJiraConfigExts < ActiveRecord::Migration[6.1]
  def change
    create_table :jira_configs, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :jira_config_id, null: false
      t.string :context, null: false, default: ''
      t.string :project_id, null: false
      t.integer :status, null: false
      t.datetime :expiration_date, null: false

      t.timestamps
    end
  end
end
