class RenameTables < ActiveRecord::Migration[6.1]
  def up
    # ReportType to TypeReport
    rename_table :report_scans, :scan_reports
    rename_table :report_pentests, :pentest_reports
    rename_column :scan_reports, :report_scan_id, :scan_report_id
    rename_column :pentest_reports, :report_pentest_id, :pentest_report_id
    change_column_default(:reports, :type, from: 'ReportScan', to: 'ScanReport')

    say_with_time 'Update reports.type == ReportScan to ScanReport' do
      query = <<-SQL
        UPDATE reports SET type = 'ScanReport' WHERE type = 'ReportScan'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    say_with_time 'Update reports.type == ReportPentest to PentestReport' do
      query = <<-SQL
        UPDATE reports SET type = 'PentestReport' WHERE type = 'ReportPentest'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    #XxOccurence to XxOccurrence
    rename_table :vm_occurences, :vm_occurrences
    rename_table :wa_occurences, :wa_occurrences
    say_with_time "Update versions.item_type == 'VmOccurence' to 'VmOccurrence'" do
      query = <<-SQL
        UPDATE versions SET item_type = 'VmOccurrence' WHERE item_type = 'VmOccurence'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time "Update versions.item_type == 'WaOccurence' to 'WaOccurrence'" do
      query = <<-SQL
        UPDATE versions SET item_type = 'WaOccurrence' WHERE item_type = 'WaOccurence'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    rename_table :aggregates_vm_occurences, :aggregates_vm_occurrences
    rename_table :aggregates_wa_occurences, :aggregates_wa_occurrences
    rename_column :aggregates_vm_occurrences, :vm_occurence_id, :vm_occurrence_id
    rename_column :aggregates_wa_occurrences, :wa_occurence_id, :wa_occurrence_id

    # Remove useless field
    remove_column :reports, :exporting
  end

  def down
    # ReportType to TypeReport
    rename_column :scan_reports, :scan_report_id, :report_scan_id
    rename_column :pentest_reports, :pentest_report_id, :report_pentest_id
    rename_table :scan_reports, :report_scans
    rename_table :pentest_reports, :report_pentests
    change_column_default(:reports, :type, from: 'ScanReport', to: 'ReportScan')

    say_with_time 'Update reports.type == ScanReport to ReportScan' do
      query = <<-SQL
        UPDATE reports SET type = 'ReportScan' WHERE type = 'ScanReport'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    say_with_time 'Update reports.type == PentestReport to ReportPentest' do
      query = <<-SQL
        UPDATE reports SET type = 'ReportPentest' WHERE type = 'PentestReport'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    #XxOccurence to XxOccurrence
    rename_table :vm_occurrences, :vm_occurences
    rename_table :wa_occurrences, :wa_occurences
    say_with_time "Update versions.item_type == 'VmOccurrence' to 'VmOccurence'" do
      query = <<-SQL
        UPDATE versions SET item_type = 'VmOccurence' WHERE item_type = 'VmOccurrence'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time "Update versions.item_type == 'WaOccurrence' to 'WaOccurence'" do
      query = <<-SQL
        UPDATE versions SET item_type = 'WaOccurence' WHERE item_type = 'WaOccurrence'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    rename_column :aggregates_vm_occurrences, :vm_occurrence_id, :vm_occurence_id
    rename_column :aggregates_wa_occurrences, :wa_occurrence_id, :wa_occurence_id
    rename_table :aggregates_vm_occurrences, :aggregates_vm_occurences
    rename_table :aggregates_wa_occurrences, :aggregates_wa_occurences

    # Readd useless field
    add_column :reports, :exporting, :boolean, default: false
  end
end
