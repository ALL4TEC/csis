# frozen_string_literal: true

require 'test_helper'

class Importers::ActionsImportJobTest < ActiveJob::TestCase
  FIXTURE_FILE_PREFIX = 'test/fixtures/files/JobTestValues'

  test 'an action is created from csv file with new aggregate if no aggregate attribute' do
    # GIVEN
    # an action plan report without any action
    report = action_plan_reports(:action_plan_report_cats)
    assert report.actions.count.zero?
    action_import = ActionImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :csv
    )
    attachment = {
      io: File.open("#{FIXTURE_FILE_PREFIX}/action_plan_import_no_aggregate.csv"),
      filename: 'action_plan_import.csv',
      content_type: 'text/csv',
      identify: false
    }
    report_action_import = ReportActionImport.create!(
      report: report,
      action_import: action_import,
      document: attachment
    )
    # WHEN calling job
    Importers::ActionsImportJob.perform_now(report_action_import)

    # THEN
    # action_import status is updated
    # 1 action is created linked to a new organizational aggregate
    report.reload
    assert_equal 'completed', action_import.status
    assert_equal report.actions.count, 1
    imported_action = report.actions.first
    assert_equal imported_action.name, 'actio1'
    assert imported_action.aggregates.first.title =~ /^org_/
  end

  test 'an action is created from csv file linked to existing aggregate if name specified' do
    # GIVEN
    # an action plan report without any action
    report = action_plan_reports(:action_plan_report_cats)
    assert report.actions.count.zero?
    action_import = ActionImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :csv
    )
    attachment = {
      io: File.open("#{FIXTURE_FILE_PREFIX}/action_plan_import_one_aggregate.csv"),
      filename: 'action_plan_import.csv',
      content_type: 'text/csv',
      identify: false
    }
    report_action_import = ReportActionImport.create!(
      report: report,
      action_import: action_import,
      document: attachment
    )
    # WHEN calling job
    Importers::ActionsImportJob.perform_now(report_action_import)

    # THEN
    # action_import status is updated
    # 2 actions are created linked to aggregate :aggregate_one
    report.reload
    assert_equal 'completed', action_import.status
    assert_equal report.actions.count, 2
    imported_action_one = report.actions.find_by(name: 'actio1')
    imported_action_two = report.actions.find_by(name: 'actio2')
    assert imported_action_one.present?
    assert imported_action_two.present?
    agg_one = Aggregate.find_by(title: 'one')
    assert_equal imported_action_one.aggregates.first, agg_one
    assert_equal imported_action_two.aggregates.first, agg_one
  end

  test 'what happens when importing 2 lines without aggregate attribute' do
    # GIVEN
    # an action plan report without any action
    report = action_plan_reports(:action_plan_report_cats)
    assert report.actions.count.zero?
    action_import = ActionImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :csv
    )
    attachment = {
      io: File.open("#{FIXTURE_FILE_PREFIX}/action_plan_import_multiple_lines_no_agg.csv"),
      filename: 'action_plan_import.csv',
      content_type: 'text/csv',
      identify: false
    }
    report_action_import = ReportActionImport.create!(
      report: report,
      action_import: action_import,
      document: attachment
    )
    # WHEN calling job
    Importers::ActionsImportJob.perform_now(report_action_import)

    # THEN
    # action_import status is updated
    # 5 actions are created linked to a new aggregate with a random title
    report.reload
    assert_equal 'completed', action_import.status
    assert_equal report.actions.count, 5
    assert_equal Action.where("name like 'actio%'").count, 5
    assert_equal Aggregate.where("title like 'org_%'").count, 5
  end
end
