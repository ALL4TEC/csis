class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name
      t.uuid :client_id, null: false

      t.timestamps
    end
    add_foreign_key :projects, :clients, column: :client_id, primary_key: :id, on_delete: :cascade
  end
end
