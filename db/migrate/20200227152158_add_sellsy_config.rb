class AddSellsyConfig < ActiveRecord::Migration[5.2]
  def change
    create_table "sellsy_configs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "encrypted_consumer_token", null: false
      t.string "encrypted_user_token", null: false
      t.string "encrypted_consumer_secret", null: false
      t.string "encrypted_user_secret", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "name", null: false
      t.string "encrypted_consumer_token_iv", null: false
      t.string "encrypted_user_token_iv", null: false
      t.string "encrypted_consumer_secret_iv", null: false
      t.string "encrypted_user_secret_iv", null: false
    end
  end
end
