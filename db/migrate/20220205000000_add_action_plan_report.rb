class AddActionPlanReport < ActiveRecord::Migration[6.1]
  def change
    add_column :actions, :due_date, :datetime
    add_column :actions, :priority, :integer, default: 0 # no_priority
    # TODO: Check that after migration all existing actions have priority set to 0
    # Move purpose and org_introduction back to reports table as it is shared
    add_column :reports, :org_introduction, :text
    add_column :reports, :purpose, :text
    # Copy purpose into reports table from pentest one when present
    say_with_time 'Moving pentest_reports.purpose to reports.purpose' do
      # source for query: https://stackoverflow.com/questions/1293330/how-can-i-do-an-update-statement-with-join-in-sql-server
      # specific to PostgreSQL, not portable to other DBMS
      query = "UPDATE reports
      SET purpose = pentest_reports.purpose
      FROM pentest_reports
      WHERE reports.id = pentest_reports.pentest_report_id
      AND pentest_reports.purpose <> '';"
      ActiveRecord::Base.connection.execute(query)
      remove_column :pentest_reports, :purpose
    end
    add_column :statistics, :action_plan_reports_count, :integer
    # Replacing all number_of_xxx by xxx_count
    rename_column :statistics, :number_of_reports, :scan_reports_count
    rename_column :statistics, :number_of_pentests, :pentest_reports_count
    rename_column :statistics, :number_of_scans, :scans_count
  end
end
