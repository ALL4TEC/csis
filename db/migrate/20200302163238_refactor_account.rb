class RefactorAccount < ActiveRecord::Migration[5.2]
  def change
    rename_table :api_accounts, :accounts
    add_column :accounts, :api_key, :string, null: true
    add_column :accounts, :encrypted_api_key, :string, null: true
    add_column :accounts, :encrypted_api_key_iv, :string, null: true
    change_column_null :accounts, :encrypted_login, true
    change_column_null :accounts, :encrypted_password, true
    change_column_null :accounts, :encrypted_login_iv, true
    change_column_null :accounts, :encrypted_password_iv, true

    # Scans
    rename_column :vm_scans, :qualys_config_id, :account_id
    rename_column :wa_scans, :qualys_config_id, :account_id

    # Teams joins
    rename_table :qualys_configs_teams, :accounts_teams
    rename_column :accounts_teams, :qualys_config_id, :account_id
    rename_index :accounts_teams, :index_qualys_configs_teams, :index_accounts_teams
  end
end
