# frozen_string_literal: true

require 'test_helper'

class ActionPlanReportsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see action_plans' do
    report = action_plan_reports(:action_plan_report_cats)
    get actions_report_path(report)
    check_not_authenticated
  end

  test 'authenticated member of project teams can see action plans' do
    user = users(:staffuser)
    sign_in user
    report = action_plan_reports(:action_plan_report_cats)
    get actions_report_path(report)
    assert_response 200
  end

  test 'unauthenticated cannot see new report action plan' do
    project = projects(:project_two)
    get new_project_action_plan_report_path(project)
    check_not_authenticated
  end

  test 'authenticated member of project teams can see new report action plan' do
    sign_in users(:staffuser)
    project = projects(:project_two)
    get new_project_action_plan_report_path(project)
    assert_response 200
  end

  test 'unauthenticated cannot see edit report action plan' do
    report = action_plan_reports(:action_plan_report_cats)
    get edit_action_plan_report_path(report)
    check_not_authenticated
  end

  # TODO
  # test 'authenticated project team member can import actions when updating report' do
  #   # GIVEN
  #   # a signed member of targetted report
  #   user = users(:staffuser)
  #   sign_in user
  #   report = action_plan_reports(:action_plan_report_cats)
  #   # WHEN sending form data
  #   put action_plan_report_path(report), params: {
  #     report: {

  #     },
  #     report_action_import: {

  #     }
  #   }
  #   # THEN ActionsImportJob has been enqueued
  #   assert report.actions
  # end
end
