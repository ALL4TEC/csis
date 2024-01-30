class QualysPwdEncrypted < ActiveRecord::Migration[5.2]
  def change
    add_column :qualys_configs, :name, :string, null: false

    rename_column :qualys_configs, :login, :encrypted_login
    add_column :qualys_configs, :encrypted_login_iv, :string, null: false

    rename_column :qualys_configs, :password, :encrypted_password
    add_column :qualys_configs, :encrypted_password_iv, :string, null: false
  end
end
