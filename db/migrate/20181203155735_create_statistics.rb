class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics, id: :uuid, default: 'uuid_generate_v4()'do |t|
      t.integer :numberOfScans, default: 0
      t.integer :levelAverage, default: 0
      t.integer :currentLevel, default: 0
      t.integer :nofExcellent, default: 0
      t.integer :nofVeryGood, default: 0
      t.integer :nofGood, default: 0
      t.integer :nofOk, default: 0
      t.integer :score, default: 0
      t.uuid :project_id, null: false
    end
    add_foreign_key :statistics, :projects, column: :project_id, primary_key: :id, on_delete: :nullify
  end
end
