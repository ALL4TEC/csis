# frozen_string_literal: true

require 'test_helper'

class DependenciesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated staff can create dependency' do
    sign_in users(:staffuser)
    agg = Aggregate.find_by(title: 'First aggregate')
    a = agg.actions.first
    a2 = agg.actions.last
    assert_not_equal a, a2
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    post action_dependencies_path(a), params:
      {
        dependency:
        {
          predecessor_id: ['', a2.id] # Les checkboxes ont une val empty pour ne pas envoyer nil
        }
      }
    assert_equal flash[:notice], I18n.t('dependencies.notices.done')
  end

  test 'authenticated staff can create multiple dependencies at the time' do
    sign_in users(:staffuser)
    agg = Aggregate.find_by(title: 'First aggregate')
    a = agg.actions.first
    deps = agg.action_ids
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    post action_dependencies_path(a), params:
      {
        dependency:
        {
          predecessor_id: ['', deps] # Les checkboxes ont une val empty pour ne pas envoyer nil
        }
      }
    assert_equal flash[:notice], I18n.t('dependencies.notices.done')
  end

  test 'unauthenticated cannot create dependency' do
    agg = Aggregate.where(title: 'First aggregate').first
    a = agg.actions.first
    a2 = agg.actions.last
    assert_not_equal a, a2
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    post action_dependencies_path(a), params:
      {
        dependency:
        {
          predecessor_id: [a2.id]
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can delete dependency' do
    sign_in users(:staffuser)
    d = Dependency.first
    post "/actions/#{d.successor_id}/dependencies/updates", params:
      {
        choice: d.predecessor_id
      }
    assert_raises ActiveRecord::RecordNotFound do
      Dependency.find(d.id)
    end
  end

  test 'authenticated staff cannot delete no dependency' do
    sign_in users(:staffuser)
    d = Dependency.first
    post "/actions/#{d.successor_id}/dependencies/updates"
    assert_equal flash[:alert], I18n.t('dependencies.notices.no_selection')
  end

  test 'unauthenticated cannot delete dependency' do
    d = Dependency.first
    post "/actions/#{d.predecessor_id}/dependencies/updates", params:
      {
        choice: d.successor_id
      }
    check_not_authenticated
  end

  test 'authenticated staff can list dependencies' do
    sign_in users(:staffuser)
    a = Dependency.first.action_s
    get action_dependencies_path(a)
    assert_select 'main table.table' do
      a.action_p.each do |action|
        assert_select 'td', text: action.aggregate.title
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'unauthenticated cannot list dependencies' do
    a = Dependency.first.action_s
    get action_dependencies_path(a)
    check_not_authenticated
  end

  test 'authenticated staff cannot create dependency if actions have != aggregates' do
    sign_in users(:staffuser)
    a = Action.where(state: 3).where.not(name: 'Action4').first
    a2 = Action.where(state: 3).where(name: 'Action4').first
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    post "/actions/#{a.id}/dependencies", params:
      {
        dependency:
        {
          predecessor_id: [a2.id]
        }
      }
    assert_equal I18n.t('actions.notices.aggregate_error'), flash[:alert]
  end

  test 'authenticated staff can view dependency creation page' do
    sign_in users(:staffuser)
    a = Action.first
    get new_action_dependency_path(a)
    assert_response :success
  end

  test 'discarded dependency is undiscarded on creation' do
    sign_in users(:staffuser)
    d = Dependency.first
    a = d.action_p
    a2 = d.action_s
    post "/actions/#{d.successor_id}/dependencies/updates", params:
      {
        choice: d.predecessor_id
      }
    assert_raises ActiveRecord::RecordNotFound do
      Dependency.find(d.id)
    end
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    post "/actions/#{a.id}/dependencies", params:
      {
        dependency:
        {
          predecessor_id: [a2.id]
        }
      }
    assert_not_empty Dependency.where(predecessor_id: a2.id, successor_id: a.id)
  end

  test 'authenticated staff cannot create dependency without predecessor' do
    sign_in users(:staffuser)
    a = Action.first
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    post "/actions/#{a.id}/dependencies", params:
      {
        dependency:
        {
          predecessor_id: []
        }
      }
    assert_redirected_to aggregate_actions_path(a.aggregate)
  end
end
