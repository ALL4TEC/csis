# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('db/migrate/20210223085356_rename_tables.rb')

# MiniTest::Unit::TestCase
class RenameTablesMigration < ActiveSupport::TestCase
  def setup
    @previous_version = 20_210_217_144_659
    @current_version = 20_210_223_085_356
    migrations_paths = ActiveRecord::Migrator.migrations_paths
    @schema_migration = ActiveRecord::Base.connection.schema_migration
    @migration_context = ActiveRecord::MigrationContext.new(migrations_paths, @schema_migration)
    @migrations = @migration_context.migrations
  end

  def reset_columns_infos
    Report.reset_column_information
    AggregateVmOccurrence.reset_column_information
    AggregateWaOccurrence.reset_column_information
  end

  def test_down_then_up
    # Migrating down from current to previous
    migrator = ActiveRecord::Migrator.new(
      :down, @migrations, @schema_migration, @previous_version
    )
    migrator.migrate
    reset_columns_infos
    # Set ReportScan and ReportPentest
    report_scan_id = SecureRandom.uuid
    project = Project.first
    project_id = project.id
    staff_id = User.staffs.first.id
    date = Time.zone.today
    query = "INSERT INTO reports (id, staff_id, project_id, created_at, updated_at, edited_at,
             exporting, type) VALUES ('#{report_scan_id}', '#{staff_id}', '#{project_id}',\
             '#{date}', '#{date}', '#{date}', false, 'ReportScan')"
    ActiveRecord::Base.connection.exec_query(query)
    report_pentest_id = SecureRandom.uuid
    project = Project.first
    project_id = project.id
    staff_id = User.staffs.first.id
    date2 = 1.day.ago
    query = "INSERT INTO reports (id, staff_id, project_id, created_at, updated_at, edited_at,
             exporting, type) VALUES ('#{report_pentest_id}', '#{staff_id}', '#{project_id}',\
             '#{date2}', '#{date2}', '#{date2}', false, 'ReportPentest')"
    ActiveRecord::Base.connection.exec_query(query)
    # Launching specific migration
    RenameTables.new.up
    reset_columns_infos
    # Check interesting fields correctly updated
    assert Report.find(report_scan_id)
    assert Report.find(report_scan_id).type == 'ScanReport'
    assert Report.find(report_pentest_id)
    assert Report.find(report_pentest_id).type == 'PentestReport'
  end

  def test_down
    # Migrate down from max to @@current_version
    ActiveRecord::Migrator.new(:down, @migrations, @schema_migration, @current_version).migrate
    reset_columns_infos
    # Set ScanReport and PentestReport
    scan_report_id = SecureRandom.uuid
    project = Project.first
    project_id = project.id
    staff_id = project.staffs.first.id
    date = Time.zone.today
    query = "INSERT INTO reports (id, staff_id, project_id, created_at, updated_at, edited_at,
             type) VALUES ('#{scan_report_id}', '#{staff_id}', '#{project_id}', '#{date}',\
             '#{date}', '#{date}', 'ScanReport')"
    ActiveRecord::Base.connection.exec_query(query)
    pentest_report_id = SecureRandom.uuid
    project = Project.first
    project_id = project.id
    staff_id = project.staffs.first.id
    date2 = 1.day.ago
    query = "INSERT INTO reports (id, staff_id, project_id, created_at, updated_at, edited_at,
             type) VALUES ('#{pentest_report_id}', '#{staff_id}', '#{project_id}', '#{date2}',\
             '#{date2}', '#{date2}', 'PentestReport')"
    ActiveRecord::Base.connection.exec_query(query)
    # Reverting specific migration
    RenameTables.new.down
    reset_columns_infos
    # Check that old type is not recognized anymore
    assert_raises ActiveRecord::SubclassNotFound do
      Report.find(scan_report_id)
    end
    assert_raises ActiveRecord::SubclassNotFound do
      Report.find(pentest_report_id)
    end
  end
end

# let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
# let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
# let(:previous_version) { 20181204143322 }
# let(:current_version) { 20190106184413 }

# subject { ActiveRecord::Migrator.new(:up, migrations, current_version).migrate }

# around do |example|
#   # Silence migrations output in specs report.
#   ActiveRecord::Migration.suppress_messages do
#     # Migrate back to the previous version
#     ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
#     # If other tests using User table ran before this one, Rails has
#     # stored information about table's columns and we need to reset those
#     # since the migration changed the database structure.
#     User.reset_column_information

#     example.run

#     # Re-update column information after the migration has been executed
#     # again in the example. This will make user attributes cache
#     # ready for other tests.
#     User.reset_column_information
#   end
# end
