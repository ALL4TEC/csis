class AddOtpMandatory < ActiveRecord::Migration[6.0]
  def change
    # Add to groups
    add_column :groups, :otp_mandatory, :boolean, default: false, null: false
    # Add to roles
    add_column :roles, :otp_mandatory, :boolean, default: false, null: false
    # Add to teams
    add_column :teams, :otp_mandatory, :boolean, default: false, null: false
    # Add to clients
    add_column :clients, :otp_mandatory, :boolean, default: false, null: false
    # Add to users
    add_column :users, :otp_mandatory, :boolean, default: false, null: false
  end
end
