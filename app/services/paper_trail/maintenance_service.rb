# frozen_string_literal: true

# Create range partitions by month for previous, current and next months
# Find all versions tables older than SINCE months ago
# For each detach partition and drop table
# By default SINCE is set to 12 months
class PaperTrail::MaintenanceService
  SINCE = ENV.fetch('KEEP_AUDIT_LOGS_FOR', 12)

  class << self
    def manage_partitions(since = SINCE)
      handle_partition_creation
      handle_partition_deletion(since)
    end

    # Create range partitions by month for previous, current and next months
    def handle_partition_creation
      today = Time.zone.today
      partitions = [today.prev_month, today, today.next_month]
      db_client = ActiveRecord::Base.connection
      partitions.each do |day|
        name = PaperTrail::Version.partition_name_for(day)
        next if db_client.table_exists?(name)

        PaperTrail::Version.create_partition(
          name: name,
          start_range: day.beginning_of_month,
          end_range: day.next_month.beginning_of_month
        )
      end
    end

    # Find all versions tables older than since months ago
    # For each detach partition and drop table
    def handle_partition_deletion(since)
      day = since.months.ago
      limit_table = PaperTrail::Version.partition_name_for(day)
      old_versions_tables = PaperTrail::Version.partitions.select { |table| table < limit_table }
      old_versions_tables.each do |table_name|
        Rails.logger.info { "Drop #{table_name}" }
        ActiveRecord::Base.connection.drop_table(table_name)
      end
    end
  end
end
