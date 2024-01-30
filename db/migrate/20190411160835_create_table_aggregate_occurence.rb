class CreateTableAggregateOccurence < ActiveRecord::Migration[5.2]
  def change
    create_table :aggregates_vm_occurences, id: false do |t|
      t.uuid :vm_occurence_id, null: false
      t.uuid :aggregate_id, null: false
    end
    create_table :aggregates_wa_occurences, id: false do |t|
      t.uuid :wa_occurence_id, null: false
      t.uuid :aggregate_id, null: false
    end
    add_foreign_key :aggregates_vm_occurences, :aggregates, column: :aggregate_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :aggregates_vm_occurences, :vm_occurences, column: :vm_occurence_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :aggregates_wa_occurences, :aggregates, column: :aggregate_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :aggregates_wa_occurences, :wa_occurences, column: :wa_occurence_id, primary_key: :id, on_delete: :cascade
    add_index :aggregates_vm_occurences, [:vm_occurence_id, :aggregate_id], unique: true, name: "index_aggregates_vm_occurences"
    add_index :aggregates_wa_occurences, [:wa_occurence_id, :aggregate_id], unique: true, name: "index_aggregates_wa_occurences"
  end
end
