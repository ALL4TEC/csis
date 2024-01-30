class AddNotes < ActiveRecord::Migration[6.0]
  def change
    create_table "notes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "staff_id", null: false
      t.uuid "report_id", null: false
      t.string "title", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "discarded_at"
      t.index ["discarded_at"], name: "index_notes_on_discarded_at"
    end

    rename_column :reports, :notes, :addendum
  end
end
