class AddAccountTeamIdAndAccountSslCheck < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts_teams, :id, :uuid, primary_key: true, default: "uuid_generate_v4()", null: false
    # This column is added to accounts table as it can be reused by other accounts
    add_column :accounts, :verify_ssl_certificate, :boolean, null: false, default: true
  end
end
