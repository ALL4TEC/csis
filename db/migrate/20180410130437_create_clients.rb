class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :internal_id, readonly: true 
      t.string :name
      t.string :web_url
      t.string :internal_type, readonly: true

      t.timestamps
    end
    add_index :clients, :internal_id, unique: true 
  end
end
