class FixActiveStorageDefault < ActiveRecord::Migration[5.2]
  def change
    # God bless : https://www.wrburgess.com/posts/2018-02-03-1.html

    add_column :active_storage_blobs, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :active_storage_blobs do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE active_storage_blobs ADD PRIMARY KEY (id);"

    add_column :active_storage_attachments, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :active_storage_attachments do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE active_storage_attachments ADD PRIMARY KEY (id);"

    add_column :active_storage_attachments, :record_uuid, :uuid, null:false # replaces t.references :record

    change_table :active_storage_attachments do |t|
      t.remove :record_id
      t.rename :record_uuid, :record_id
    end

    add_column :active_storage_attachments, :blob_uuid, :uuid, null:false # replaces t.references :blob

    change_table :active_storage_attachments do |t|
      t.remove :blob_id
      t.rename :blob_uuid, :blob_id
    end
  end
end
