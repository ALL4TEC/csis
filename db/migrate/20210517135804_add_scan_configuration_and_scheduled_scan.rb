class AddScanConfigurationAndScheduledScan < ActiveRecord::Migration[6.1]
  def change
    create_table :scan_configurations, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :launcher_id, null: false
      t.integer :scanner, default: 0, null: false
      t.string :scan_type
      t.string :scan_name
      t.string :target, null: false
      t.string :parameters
      t.boolean :auto_import, default: true
      t.boolean :auto_aggregate, default: true, null: false
      t.boolean :auto_aggregate_mixing, default: true, null: false

      t.timestamps
    end
    add_column :scan_launches, :scan_configuration_id, :uuid
    add_foreign_key :scan_launches, :scan_configurations, column: :scan_configuration_id, primary_key: :id, on_delete: :nullify

    # For each scan_launch, copy scan_configuration columns to scan_configurations
    # and link to new entry
    say_with_time "Copy scan_configuration columns from scan_launch to scan_configuration" do
      query = <<-SQL
        INSERT INTO scan_configurations (launcher_id, created_at, updated_at, scanner, scan_type, scan_name,
          target, parameters, auto_import, auto_aggregate, auto_aggregate_mixing)
        SELECT launcher_id, created_at, updated_at, scanner, scan_type, scan_name,
          target, parameters, auto_import, auto_aggregate, auto_aggregate_mixing
        FROM scan_launches
      SQL
      ActiveRecord::Base.connection.execute(query)
      # Update ScanLaunch with ScanConfiguration.id
      ScanConfiguration.all.each do |sc|
        query2 = <<-SQL
          UPDATE scan_launches
          SET scan_configuration_id = \'#{sc.id}\'
          WHERE scanner = #{sc.scanner.to_i}
          AND scan_type = \'#{sc.scan_type}\'
          AND scan_name = \'#{sc.scan_name}\'
          AND target = \'#{sc.target}\'
          AND parameters = \'#{sc.parameters}\'
          AND auto_import = #{sc.auto_import}
          AND auto_aggregate = #{sc.auto_aggregate}
          AND auto_aggregate_mixing = #{sc.auto_aggregate_mixing}
        SQL
        ActiveRecord::Base.connection.execute(query2)
      end
    end

    # Remove corresponding scan_configuration columns
    %i[launcher_id scanner scan_type scan_name target parameters auto_import auto_aggregate
       auto_aggregate_mixing].each do |col|
      remove_column :scan_launches, col
    end

    # Add ScheduledScan
    create_table :scheduled_scans, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :project_id, null: false
      t.uuid :scan_configuration_id, null: false
      t.integer :report_action, default: 0, null: false
      # To support activation/deactivation
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :scheduled_scans, :discarded_at
    add_foreign_key :scheduled_scans, :scan_configurations, column: :scan_configuration_id, primary_key: :id, on_delete: :cascade
  end
end
