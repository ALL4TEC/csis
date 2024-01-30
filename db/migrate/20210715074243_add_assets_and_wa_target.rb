class AddAssetsAndWaTarget < ActiveRecord::Migration[6.1]
  def change
    # Api_key field is encrypted
    remove_column :accounts, :api_key
    # Adding secret_key to Account
    add_column :accounts, :encrypted_secret_key, :string, null: true
    add_column :accounts, :encrypted_secret_key_iv, :string, null: true
    # Creating assets
    create_table "assets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "name", null: false
      t.string "description"
      t.integer "category", null: false
      t.string "os" # Utile ? Pas vraiment générique ...
      t.integer "confidentiality", default: 0, null: false
      t.integer "integrity", default: 0, null: false
      t.integer "availability", default: 0, null: false
      t.uuid "account_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "discarded_at"
      t.index ["discarded_at"], name: "index_assets_on_discarded_at"
    end
    create_table "assets_targets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "asset_id", null: false
      t.uuid "target_id", null: false
    end
    add_index :assets_targets, [:asset_id, :target_id], unique: true

    create_table "assets_projects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "asset_id", null: false
      t.uuid "project_id", null: false
    end
    add_index :assets_projects, [:asset_id, :project_id], unique: true

    # Using STI for targets
    rename_table :vm_targets, :targets
    add_column :targets, :name, :string
    add_column :targets, :kind, :string, default: "VmTarget", null: false # Type
    add_column :targets, :reference_id, :string
    add_column :targets, :discarded_at, :datetime
    add_index :targets, :discarded_at

    change_column :targets, :ip, :inet, null: true

    # Store relevant IP in VmOccurrence
    add_column :vm_occurrences, :ip, :inet

    # Replacing vm_occ <-> target by vm_occ <-> scan
    remove_foreign_key :vm_occurrences, :targets
    rename_column :vm_occurrences, :target_id, :scan_id

    say_with_time 'Link VmOccurrence to VmScan not Target but keep IP' do
      query = <<-SQL
      UPDATE vm_occurrences
      SET scan_id = targets.scan_id,
      ip = targets.ip
      FROM targets
      WHERE vm_occurrences.scan_id = targets.id
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    add_foreign_key :vm_occurrences, :vm_scans, column: :scan_id, on_delete: :nullify

    # Handling existing WaScans
    add_column :targets, :url, :string
    remove_foreign_key :targets, :vm_scans

    say_with_time 'Move WaScan webapps to Targets' do
      query = <<-SQL
        INSERT INTO targets (name, reference_id, url, created_at, updated_at, scan_id)
        SELECT DISTINCT web_app_name, web_app_id, web_app_url, created_at, updated_at, id FROM wa_scans
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    say_with_time 'Change WaTargets to right kind' do
      query = <<-SQL
        UPDATE targets
        SET kind = 'WaTarget'
        WHERE url IS NOT NULL
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    # Making Target <-> Scan relation MtoM

    create_table "targets_scans", id: false, force: :cascade do |t|
      t.uuid "target_id", null: false
      t.uuid "scan_id", null: false
      t.string "scan_type", null: false
    end
    add_index :targets_scans, [:target_id, :scan_id], unique: true

    Target.wa_targets.each do |target|
      TargetScan.create!(target_id: target.id, scan_id: target.scan_id, scan_type: 'WaScan')
    end

    Target.vm_targets.group_by(&:ip).each do |ip, targets|
      if targets.count == 1
        target = targets.first
        TargetScan.create!(target_id: target.id, scan_id: target.scan_id, scan_type: 'VmScan')
        next
      end
      keep = targets.shift
      target_id = keep.id
      scan_id = keep.scan_id

      say_with_time 'Point occurrences to right target' do
        query = <<-SQL
          UPDATE vm_occurrences
          SET scan_id = '#{scan_id}'
          WHERE scan_id IN ('#{targets.map(&:scan_id).join("','")}')
        SQL
        ActiveRecord::Base.connection.execute(query)
      end

      targets.each do |target|
        TargetScan.create(target_id: target_id, scan_id: target.scan_id)
        target.destroy
      end
    end

    remove_column :targets, :scan_id
    remove_column :wa_scans, :web_app_name
    remove_column :wa_scans, :web_app_id
    remove_column :wa_scans, :web_app_url
  end
end
