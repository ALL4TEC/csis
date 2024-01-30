# This migration comes from action_text (originally 20180528164100)
class CreateActionTextTables < ActiveRecord::Migration[6.0]
  def change
    create_table "action_text_rich_texts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "name", null: false
      t.text "body"
      t.string "record_type", null: false
      t.uuid "record_id", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
    end
  end
end
