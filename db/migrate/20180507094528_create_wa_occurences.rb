class CreateWaOccurences < ActiveRecord::Migration[5.2]
  def change
    create_table :wa_occurences, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.text :result
      t.string :uri
      t.uuid :vulnerability_id
      t.uuid :wa_target_id
      t.timestamps
    end
    add_foreign_key :wa_occurences, :vulnerabilities, column: :vulnerability_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :wa_occurences, :wa_targets, column: :wa_target_id, primary_key: :id, on_delete: :cascade
  end
end
