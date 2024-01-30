# frozen_string_literal: true

class DeviseCreateStaff < ActiveRecord::Migration[5.2]
  def change
    create_table :staff, id: :uuid, default: 'uuid_generate_v4()' do |t|
      ## Database authenticatable
      t.string :email, null: false

      t.string :full_name, null: false
      t.string :avatar_url

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Omniauthable
      t.string :provider
      t.string :uid

      t.timestamps null: false
    end

    add_index :staff, :email, unique: true
  end
end
