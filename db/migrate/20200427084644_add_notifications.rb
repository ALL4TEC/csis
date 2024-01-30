class AddNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :resource_id
      t.string :resource_type
      t.integer 'version_id', nil: false          # PaperTrail::Version.id -> integer
      t.datetime 'created_at', nil: false
      t.integer 'state', default: 0, nil: false
    end
    add_index :notifications, [:resource_type, :resource_id]

    add_column :staffs, :public_key, :text
  end
end
