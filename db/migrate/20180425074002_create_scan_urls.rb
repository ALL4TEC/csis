class CreateScanUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :scan_urls, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :url, null: false
      t.uuid :scan_id, null: false

      t.timestamps
    end
  end
end
