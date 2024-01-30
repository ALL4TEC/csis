class PartitionVersions < ActiveRecord::Migration[6.1]
  def up
    # proc is used for partition keys containing expressions
    create_range_partition :versions_range_records, partition_key: :created_at do |t|
      t.string "item_type", null: false
      t.string "event", null: false
      t.string "whodunnit"
      t.text "object"
      t.datetime "created_at"
      t.text "object_changes"
      t.uuid "item_id"
    end

    # For each month since 18.months.ago
    # We create a range partition
    # And attach corresponding ranged existing data from versions table
    (0..17).each do |index|
      day = index.months.ago
      year = day.year
      month = day.month
      table_name = "versions_y#{year}_m#{month}"
      start_range = day.beginning_of_month
      end_range = day.next_month.beginning_of_month
      # optional name argument is used to specify child table name
      create_range_partition_of(
        :versions_range_records,
        name: table_name,
        start_range: start_range,
        end_range: end_range
      )
      # Copy data from versions table
      say_with_time "Copy versions of #{year}-#{month}" do
        query = <<-SQL
          INSERT INTO #{table_name} (id, item_type, event, whodunnit, object, created_at, object_changes, item_id)
          SELECT id, item_type, event, whodunnit, object, created_at, object_changes, item_id
          FROM versions
          WHERE created_at BETWEEN \'#{start_range}\' AND \'#{end_range}\'
        SQL
        ActiveRecord::Base.connection.execute(query)
      end
    end

    # Delete versions table
    drop_table :versions
    # Rename versions_range_records to versions
    rename_table :versions_range_records, :versions
    # Create indexes for item_type and event
    add_index_on_all_partitions :versions, :item_type, name: :index_versions_item_type
    add_index_on_all_partitions :versions, :event, name: :index_versions_event
  end
end
