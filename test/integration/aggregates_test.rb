# frozen_string_literal: true

require 'test_helper'

class AggregatesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated staff can list aggregates' do
    r = scan_reports(:mapui)
    sign_in users(:staffuser)
    get report_aggregates_path(r)
    assert_select 'main' do
      Aggregate.where(report: r).page(1).each do |aggregate|
        assert_select '.agg_title', text: aggregate.title
      end
    end
  end

  test 'authenticated staff can reorder aggregates by status,severity,visibility,title by
    default' do
    r = scan_reports(:mapui)
    sign_in users(:staffuser)
    post apply_order_report_aggregates_path(r)
    assert_select 'main' do
      Aggregate.where(report: r).page(1).each do |aggregate|
        assert_select '.agg_title', text: aggregate.title
      end
    end
  end

  test 'unauthenticated cannot save report order preference' do
    report = scan_reports(:mapui)
    put order_report_aggregates_path(report)
    check_not_authenticated
  end

  test 'unauthenticated cannot apply report order preference' do
    report = scan_reports(:mapui)
    post apply_order_report_aggregates_path(report)
    check_not_authenticated
  end

  test 'authenticated staff can save report order preference' do
    report = scan_reports(:mapui)
    sign_in users(:staffuser)
    new_order = %w[title status visibility severity]
    assert_not_equal(report.aggregates_order_by, new_order)
    put order_report_aggregates_path(report), params: {
      aggregates_order_by: new_order
    }
    assert_response :success
    assert_equal(report.reload.aggregates_order_by, new_order)
  end

  test 'authenticated staff can apply report order preference' do
    report = scan_reports(:mapui)
    sign_in users(:staffuser)
    post apply_order_report_aggregates_path(report)
    assert_response :success
  end

  test 'unauthenticated cannot list aggregates' do
    r = scan_reports(:mapui)
    get report_aggregates_path(r)
    check_not_authenticated
  end

  test 'unauthenticated cannot consult aggregate' do
    aggregate = Aggregate.first
    get "/aggregates/#{aggregate.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if an aggregate exists' do
    get '/aggregates/ABC'
    check_not_authenticated
  end

  test 'authenticated staff can view aggregate' do
    sign_in users(:staffuser)
    a = Aggregate.first
    get "/aggregates/#{a.id}"
    assert_select 'h4', text: a.title
  end

  test 'authenticated staff cannot consult inexistant aggregate' do
    sign_in users(:staffuser)
    get '/aggregates/ABC'
    assert_redirected_to projects_path
  end

  test 'unauthenticated cannot update aggregate' do
    a = Aggregate.first
    put "/aggregates/#{a.id}", params:
      {
        aggregate:
        {
          title: 'test',
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can update aggregate' do
    sign_in users(:staffuser)
    a = Aggregate.first
    put "/aggregates/#{a.id}", params:
      {
        aggregate:
        {
          title: 'test',
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }
    updated_a = Aggregate.find(a.id)
    assert_equal 'test', updated_a.title
  end

  test 'authenticated staff cannot update aggregate without title' do
    sign_in users(:staffuser)
    a = Aggregate.first
    put "/aggregates/#{a.id}", params:
      {
        aggregate:
        {
          title: nil,
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }
    updated_a = Aggregate.find(a.id)
    assert_equal a.title, updated_a.title
  end

  test 'authenticated staff cannot update non-existent aggregate' do
    sign_in users(:staffuser)
    put '/aggregates/ABC', params:
    {
      aggregate:
      {
        title: 'test',
        kind: :system,
        status: :information_gathered,
        severity: :critical,
        visibility: :shown
      }
    }
    assert_redirected_to projects_path
  end

  test 'unauthenticated cannot consult non-existent aggregate form' do
    get '/aggregates/ABC/edit'
    check_not_authenticated
  end

  test 'authenticated staff cannot consult non-existent aggregate form' do
    sign_in users(:staffuser)
    get '/aggregates/ABC/edit'
    assert_redirected_to projects_path
  end

  test 'unauthenticated cannot consult existent aggregate form' do
    a = Aggregate.first
    get "/aggregates/#{a.id}/edit"
    check_not_authenticated
  end

  test 'authenticated staff can consult existent aggregate form' do
    sign_in users(:staffuser)
    a = Aggregate.first
    get "/aggregates/#{a.id}/edit"
    assert_response :success
  end

  test 'unauthenticated cannot view new aggregate form' do
    r = Report.first
    get new_report_aggregate_path(r)
    check_not_authenticated
  end

  test 'authenticated can view new aggregate form' do
    sign_in users(:staffuser)
    r = Report.first
    get new_report_aggregate_path(r)
    assert_response :success
  end

  test 'unauthenticated cannot create new aggregate' do
    r = Report.first
    post "/reports/#{r.id}/aggregates", params:
      {
        aggregate:
        {
          title: 'test',
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can create new aggregate' do
    sign_in users(:staffuser)
    r = Report.first
    post "/reports/#{r.id}/aggregates", params:
      {
        aggregate:
        {
          title: 'test',
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }
    updated_a = Aggregate.find_by(title: 'test')
    assert_equal r.id, updated_a.report_id
  end

  test 'authenticated staff cannot create new aggregate without title' do
    sign_in users(:staffuser)
    r = Report.first
    post "/reports/#{r.id}/aggregates", params:
      {
        aggregate:
        {
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }
    assert_response :success
  end

  test 'unauthenticated cannot delete aggregate' do
    a = Aggregate.first
    delete "/aggregates/#{a.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if an aggregate exists trying to delete it' do
    delete '/aggregates/ABC'
    check_not_authenticated
  end

  test 'authenticated staff cannot delete non-existent aggregate' do
    sign_in users(:staffuser)
    delete '/aggregates/ABC'
    assert_redirected_to projects_path
  end

  test 'authenticated staff can delete existent aggregate' do
    a = aggregates(:aggregate_one)
    sign_in users(:staffuser)
    delete "/aggregates/#{a.id}"
    assert_raises ActiveRecord::RecordNotFound do
      a = Aggregate.find(a.id)
    end
  end

  test 'unauthenticated cannot move an aggregate up' do
    a = Aggregate.first
    post up_aggregate_path(a)
    check_not_authenticated
  end

  test 'unauthenticated cannot move an aggregate down' do
    a = Aggregate.first
    post down_aggregate_path(a)
    check_not_authenticated
  end

  test 'authenticated staff can move an aggregate up' do
    a = Aggregate.first
    sign_in users(:staffuser)
    post up_aggregate_path(a)
    assert_redirected_to report_aggregates_path(a.report)
  end

  test 'authenticated staff can move an aggregate down' do
    a = Aggregate.first
    sign_in users(:staffuser)
    post down_aggregate_path(a)
    assert_redirected_to report_aggregates_path(a.report)
  end

  test 'if first aggregate move up, it gets to the bottom' do
    report = pentest_reports(:hospiville)
    a = Aggregate.find_by(report: report, kind: 1, rank: 1)
    sign_in users(:staffuser)
    post up_aggregate_path(a)
    max = Aggregate.where(report: report, kind: 1).order('rank ASC').pluck(:rank).last
    assert_equal max, Aggregate.find(a.id).rank
  end

  test 'if last aggregate move down, it gets to the top' do
    report = pentest_reports(:hospiville)
    a = Aggregate.where(report: report, kind: 1).order('rank ASC').last
    sign_in users(:staffuser)
    post down_aggregate_path(a)
    assert_equal 1, Aggregate.find(a.id).rank
  end

  test 'after aggregate deletion other aggregates still have progressive rank' do
    a = aggregates(:aggregate_four)
    sign_in users(:staffuser)
    delete "/aggregates/#{a.id}"
    assert_raises ActiveRecord::RecordNotFound do
      a = Aggregate.find(a.id)
    end
    r = Aggregate.where(report: a.report, kind: a.kind).order('rank DESC').pluck(:rank)
    prev = r.count + 1
    r.each do |i|
      assert_equal i + 1, prev
      prev = i
    end
  end

  test 'authenticated staff can update aggregates kind without breaking ranks' do
    a = aggregates(:aggregate_four)
    put "/aggregates/#{a.id}", params:
      {
        aggregate:
        {
          title: 'test',
          kind: :system,
          status: :information_gathered,
          severity: :critical,
          visibility: :shown
        }
      }

    sys = Aggregate.where(report: a.report, kind: :system).order('rank DESC').pluck(:rank)
    prev = sys.count + 1
    sys.each do |i|
      assert_equal i + 1, prev
      prev = i
    end

    app = Aggregate.where(report: a.report, kind: :applicative).order('rank DESC').pluck(:rank)
    prev = app.count + 1
    app.each do |i|
      assert_equal i + 1, prev
      prev = i
    end
  end

  test 'authenticated can change aggregate visibility to shown' do
    sign_in users(:staffuser)
    a = Aggregate.first
    a.visibility = 'hidden'
    a.save
    post toggle_visibility_aggregate_path(a)
    assert_equal flash[:notice], I18n.t('aggregates.notices.visibility_updated')
    assert_equal 'shown', Aggregate.find(a.id).visibility
  end

  test 'unauthenticated cannot change aggregate visibility to shown' do
    a = Aggregate.first
    a.visibility = 'hidden'
    a.save
    post toggle_visibility_aggregate_path(a)
    check_not_authenticated
  end

  test 'authenticated can change aggregate visibility to hidden' do
    sign_in users(:staffuser)
    a = Aggregate.first
    a.visibility = 'shown'
    a.save
    post toggle_visibility_aggregate_path(a)
    assert_equal flash[:notice], I18n.t('aggregates.notices.visibility_updated')
    assert_equal 'hidden', Aggregate.find(a.id).visibility
  end

  test 'unauthenticated cannot change aggregate visibility to hidden' do
    a = Aggregate.first
    a.visibility = 'shown'
    a.save
    post toggle_visibility_aggregate_path(a)
    check_not_authenticated
  end
end
