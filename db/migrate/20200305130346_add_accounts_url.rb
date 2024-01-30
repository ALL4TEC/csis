class AddAccountsUrl < ActiveRecord::Migration[5.2]
  def up
    add_column :accounts, :url, :string

    Account.update_all(url: 'qualysapi.qualys.eu')

    change_column_null :accounts, :url, false
  end

  def down
    remove_column :accounts, :url
  end
end
