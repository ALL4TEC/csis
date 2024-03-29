class TwoFactorAuthenticationAddToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :second_factor_attempts_count, :integer, default: 0
    add_column :users, :encrypted_otp_secret_key, :string
    add_column :users, :encrypted_otp_secret_key_iv, :string
    add_column :users, :encrypted_otp_secret_key_salt, :string
    add_column :users, :direct_otp, :string
    add_column :users, :direct_otp_sent_at, :datetime
    add_column :users, :totp_timestamp, :timestamp
    # Handle manual activation
    add_column :users, :otp_activated_at, :datetime
    add_column :users, :totp_configuration_token, :string

    add_index :users, :encrypted_otp_secret_key, unique: true
  end
end
