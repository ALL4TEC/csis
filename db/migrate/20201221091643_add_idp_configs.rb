class AddIdpConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :idp_configs, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.string :idp_metadata_url
      t.string :idp_entity_id
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :idp_configs, :name, unique: true
  end
end
