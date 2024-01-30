# frozen_string_literal: true

require 'test_helper'

class PaperTrail::MaintenanceJobTest < ActiveJob::TestCase
  test 'that partition creation is well handled' do
    # GIVEN
    # next month versions partition does not exist
    today = Time.zone.today
    next_month = today.next_month
    next_month_table_name = PaperTrail::Version.partition_name_for(next_month)
    db_client = ActiveRecord::Base.connection

    if db_client.table_exists?(next_month_table_name)
      db_client.execute("DROP TABLE #{next_month_table_name}")
    end
    assert_not(db_client.table_exists?(next_month_table_name))
    # WHEN
    PaperTrail::MaintenanceJob.perform_now
    # THEN
    # next month versions partition is created
    assert db_client.table_exists?(next_month_table_name)
  end

  test 'that partition deletion is well handled' do
    # GIVEN
    # 1 old version partition
    db_client = ActiveRecord::Base.connection
    old_day = 13.months.ago
    old_table_name = PaperTrail::Version.partition_name_for(old_day)
    unless db_client.table_exists?(old_table_name)
      PaperTrail::Version.create_partition(
        name: old_table_name,
        start_range: old_day.beginning_of_month,
        end_range: old_day.next_month.beginning_of_month
      )
    end
    assert db_client.table_exists?(old_table_name)
    # WHEN
    PaperTrail::MaintenanceJob.perform_now
    # MaintenanceService is called with since = 12
    # THEN
    # Old table is deleted
    assert_not db_client.table_exists?(old_table_name)
  end
end
