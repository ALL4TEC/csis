class CreateVmOccurences < ActiveRecord::Migration[5.2]
  def change
    create_table :vm_occurences, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.text :result
      t.string :netbios
      t.string :fqdn
      t.uuid :vulnerability_id
      t.uuid :vm_target_id
      
      t.timestamps
    end
    add_foreign_key :vm_occurences, :vulnerabilities, column: :vulnerability_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :vm_occurences, :vm_targets, column: :vm_target_id, primary_key: :id, on_delete: :cascade
  end
end
