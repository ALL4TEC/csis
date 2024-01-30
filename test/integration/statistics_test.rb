# frozen_string_literal: true

require 'test_helper'

class StatisticsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list statistics' do
    get statistics_path
    check_not_authenticated
  end

  test 'unauthenticated cannot consult statistics' do
    project = Project.first
    get "/projects/#{project.id}/statistics"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if statistics exists' do
    get '/projects/ABC/statistics'
    check_not_authenticated
  end

  test 'authenticated staff can show statistics' do
    sign_in users(:staffuser)
    get statistics_path
    assert_response :success
  end

  test 'authenticated staff can display view 0 of statistics' do
    sign_in users(:staffuser)
    get statistics_path, params: { view: 0 }
    assert_response :success
  end

  test 'authenticated staff can filter by vulnerability kinds in views 0 and 2 of statistics' do
    sign_in users(:staffuser)
    get statistics_path, params: { view: 0, kinds: %w[1 2] }
    assert_response :success
    get statistics_path, params: { view: 2, kinds: %w[1 2 3] }
    assert_response :success
  end

  test 'authenticated staff can filter reports in views 0 and 2 of statistics' do
    sign_in users(:staffuser)
    get statistics_path, params: { view: 0, reports: [Report.first] }
    assert_response :success
    get statistics_path, params: { view: 2, reports: [Report.first] }
    assert_response :success
  end

  test 'authenticated staff can define maximum nb of elements per piechart
        in views 0 and 2 of statistics' do
    sign_in users(:staffuser)
    get statistics_path, params: { view: 0, limit: 2 }
    assert_response :success
    get statistics_path, params: { view: 2, limit: 2 }
    assert_response :success
  end

  test 'authenticated staff can display view 1 of statistics' do
    sign_in users(:staffuser)
    get statistics_path, params: { view: 1 }
    assert_response :success
  end

  test 'authenticated staff can display view 3 of statistics' do
    sign_in users(:staffuser)
    get statistics_path, params: { view: 3 }
    assert_response :success
  end

  test 'authenticated staff can view statistics' do
    sign_in users(:staffuser)
    p = Project.first
    get "/projects/#{p.id}/statistics"
    assert_select 'h4', text: p.name
  end

  test 'authenticated staff cannot consult inexistant statistics' do
    sign_in users(:staffuser)
    get '/projects/ABC/statistics'
    assert_redirected_to projects_path
  end

  test 'unauthenticated cannot update certificate' do
    p = Project.first
    post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          transparency_level: 'clearness',
          project_id: p.id
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can update certificate to secretive' do
    update_certificate('secretive')
  end

  test 'authenticated staff can update certificate to obfuscate' do
    update_certificate('obfuscate')
  end

  test 'authenticated staff can update certificate to clearness' do
    update_certificate('clearness')
  end

  test 'authenticated staff cannot update non-existent certificate' do
    sign_in users(:staffuser)
    l = Language.ids
    post '/projects/ABC/statistics/update_certificate', params:
    {
      certificate:
      {
        transparency_level: 'clearness',
        language_ids: l
      }
    }
    assert_redirected_to projects_path
  end

  test 'throw error when missing transparency in update_certificate' do
    sign_in users(:staffuser)
    p = Project.first
    l = Language.ids
    assert_raises MissingRequiredParameterError do
      post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          language_ids: l
        }
      }
    end
  end

  test 'throw error when missing languages in update_certificate' do
    sign_in users(:staffuser)
    p = Project.first
    assert_raises MissingRequiredParameterError do
      post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          transparency_level: 'clearness'
        }
      }
    end
  end

  test 'throw error when invalid transparency level in update_certificate' do
    sign_in users(:staffuser)
    p = Project.first
    l = Language.ids
    assert_raises InvalidParameterError do
      post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          transparency_level: 'karaoke',
          language_ids: l
        }
      }
    end
  end

  test 'unauthenticated cannot see export statistics page' do
    get statistics_export_path
    check_not_authenticated
  end

  test 'authenticated contact can see export statistics page' do
    sign_in users(:c_one)
    get statistics_export_path
    assert_response :success
  end

  test 'authenticated staff can see export statistics page' do
    sign_in users(:staffuser)
    get statistics_export_path
    assert_response :success
  end

  test 'unauthenticated cannot export statistics' do
    post statistics_export_path
    check_not_authenticated
  end

  test 'authenticated contact can export some statistics' do
    sign_in users(:staffuser)
    # Wrong object
    post statistics_export_path, params: {
      object: 'unknown',
      format: 'csv'
    }
    assert_redirected_to statistics_export_path
    assert_equal I18n.t('statistics.exports.errors.wrong_object'), flash[:alert]
    # Wrong columns
    post statistics_export_path, params: {
      object: 'report',
      columns: ['unknown'],
      format: 'csv'
    }
    assert_redirected_to statistics_export_path
    assert_equal I18n.t('statistics.exports.errors.wrong_columns'), flash[:alert]
    # Good everything
    post statistics_export_path, params: {
      object: 'report',
      columns: Report.exportable_columns,
      format: 'csv'
    }
    assert_response :success
    assert(response.body.present?)
  end

  test 'authenticated staff can export some statistics' do
    sign_in users(:staffuser)
    # Wrong object
    post statistics_export_path, params: {
      object: 'unknown',
      format: 'csv'
    }
    assert_redirected_to statistics_export_path
    assert_equal I18n.t('statistics.exports.errors.wrong_object'), flash[:alert]
    # Wrong columns
    post statistics_export_path, params: {
      object: 'report',
      columns: ['unknown'],
      format: 'csv'
    }
    assert_redirected_to statistics_export_path
    assert_equal I18n.t('statistics.exports.errors.wrong_columns'), flash[:alert]
    # Good everything
    post statistics_export_path, params: {
      object: 'report',
      columns: Report.exportable_columns,
      format: 'csv'
    }
    assert_response :success
    assert(response.body.present?)
  end

  private

  def update_certificate(level)
    sign_in users(:staffuser)
    p = Project.first
    l = Language.ids
    post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          transparency_level: level,
          language_ids: l
        }
      }
    updated_p = Project.find_by(id: p.id)
    assert_equal(
      level,
      updated_p.certificate.transparency_level
    )
  end
end
