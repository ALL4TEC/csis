class AddFieldsToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :state, :integer, default: 0
    add_column :contacts, :token, :string, default: nil
  end
end
