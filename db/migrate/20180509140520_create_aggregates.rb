class CreateAggregates < ActiveRecord::Migration[5.2]
  def change
    create_table :aggregates, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :title, null: false
      t.text :description
      t.text :solution
      t.integer :vuln_type
      t.integer :severity
      t.uuid :report_id

      t.timestamps
    end
    add_column :vm_occurences, :aggregate_id, :uuid
    add_column :wa_occurences, :aggregate_id, :uuid
    add_foreign_key :aggregates, :reports, column: :report_id, primary_key: :id, on_delete: :nullify
    add_foreign_key :vm_occurences, :aggregates, column: :aggregate_id, primary_key: :id, on_delete: :nullify
    add_foreign_key :wa_occurences, :aggregates, column: :aggregate_id, primary_key: :id, on_delete: :nullify
    add_column :vulnerabilities, :status, :integer, using: 'status::integer' 
  end
end
