class AddSecondEmailFieldToContactsAndStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :notification_email, :string
    add_column :contacts, :ref_identifier, :string
    add_column :staffs, :notification_email, :string
  end
end
