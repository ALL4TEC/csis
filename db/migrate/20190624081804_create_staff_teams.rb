class CreateStaffTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :qualys_configs, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :login, null: false
      t.string :password, null: false

      t.timestamps
    end

    create_table :teams, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name, null: false
      t.uuid :qualys_config_id

      t.timestamps
    end

    add_column :projects, :team_id, :uuid
    add_column :teams, :discarded_at, :datetime
    add_index :teams, :discarded_at

    create_table :staff_teams, id: false do |t|
      t.uuid :staff_id, null: false
      t.uuid :team_id, null: false
    end

    add_foreign_key :staff_teams, :staff, column: :staff_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :staff_teams, :teams, column: :team_id, primary_key: :id, on_delete: :cascade
    add_index :staff_teams, [:team_id, :staff_id], unique: true

    add_column :staff, :state, :integer, default: 0
    add_column :staff, :token, :string, default: nil
    add_column :staff, :discarded_at, :datetime
    add_index :staff, :discarded_at
  end
end
