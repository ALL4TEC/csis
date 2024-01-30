# frozen_string_literal: true

require 'test_helper'

class ActionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list actions' do
    get actions_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list trashed actions' do
    get trashed_actions_path
    check_not_authenticated
  end

  test 'unauthenticated cannot consult action' do
    action = Action.first
    get "/actions/#{action.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if an action exists' do
    get '/actions/ABC'
    check_not_authenticated
  end

  test 'authenticated staff can list active actions' do
    sign_in users(:staffuser)
    get actions_path
    assert_select 'main table.table' do
      Action.active.each do |action|
        assert_select 'td', text: action.aggregate.title
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated staff can list clotured actions' do
    sign_in users(:staffuser)
    get clotured_actions_path
    assert_select 'main table.table' do
      Action.clotured.each do |action|
        assert_select 'td', text: action.aggregate.title
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated staff can list archived actions' do
    sign_in users(:staffuser)
    get archived_actions_path
    assert_select 'main table.table' do
      Action.archived.each do |action|
        assert_select 'td', text: action.aggregate.title
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated staff can list actions from an aggregate' do
    sign_in users(:staffuser)
    a = Action.first.aggregate
    get aggregate_actions_path(a)
    assert_select 'main table.table' do
      a.actions.page(1).each do |action|
        assert_select 'td', text: action.aggregate.title
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated staff can list trashed actions' do
    # On utilise le cyberanalyst parce qu'il n'a pas de notification active
    # liée à une action.
    sign_in users(:cyberanalyst)
    Action.discard_all
    get trashed_actions_path
    assert_select 'main table.table' do
      Action.trashed.page(1).each do |action|
        assert_select 'td', text: action.aggregate.title
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated staff can filter active actions by name containing' do
    filter_actions_by_name('3')
  end

  test 'authenticated staff can filter clotured actions by name containing' do
    filter_actions_by_name('2', 'clotured_')
  end

  test 'authenticated staff can filter archived actions by name containing' do
    filter_actions_by_name('4', 'archived_')
  end

  test 'authenticated staff can filter actions by client equal to' do
    filter_by_equal_to('client')
  end

  test 'authenticated staff can filter actions by project equal to' do
    filter_by_equal_to('project')
  end

  test 'authenticated staff can filter actions by report equal to' do
    filter_by_equal_to('report')
  end

  test 'authenticated staff can filter actions by aggregate id equal to' do
    # Nom surprenant mais dû au passage aggregate <-> action en many2many
    filter_by_equal_to('aggregates_id', 0)
  end

  test 'authenticated staff can filter actions by state equal to' do
    filter_by_equal_to('state', 0)
  end

  test 'authenticated staff can filter actions by meta state equal to' do
    filter_by_equal_to('meta_state', 0)
  end

  # TODO: idem in list and trashed

  test 'authenticated staff can view action' do
    sign_in users(:staffuser)
    a = Action.first
    get "/actions/#{a.id}"
    assert_select 'h4', text: a.name
  end

  test 'authenticated staff cannot consult inexistant action' do
    sign_in users(:staffuser)
    get '/actions/ABC'
    assert_redirected_to actions_path
  end

  test 'unauthenticated cannot update action' do
    a = Action.first
    put "/actions/#{a.id}", params:
      {
        act:
        {
          name: 'test',
          description: a.description,
          aggregate_ids: a.aggregate_ids
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can update action' do
    sign_in users(:staffuser)
    a = Action.first
    put "/actions/#{a.id}", params:
      {
        act:
        {
          name: 'test',
          description: a.description,
          aggregate_ids: a.aggregate_ids
        }
      }
    updated_a = Action.find(a.id)
    assert_equal 'test', updated_a.name
  end

  test 'authenticated staff cannot update non-existent action' do
    sign_in users(:staffuser)
    put '/actions/ABC', params:
      {
        act:
        {
          name: 'test',
          description: 'test',
          aggregate_ids: ['58ed1d83-12f1-4575-bbea-1537f8add561']
        }
      }
    assert_redirected_to actions_path
  end

  test 'unauthenticated cannot consult non-existent action form' do
    get '/actions/ABC/edit'
    check_not_authenticated
  end

  test 'authenticated staff cannot consult non-existent action form' do
    sign_in users(:staffuser)
    get '/actions/ABC/edit'
    assert_redirected_to actions_path
  end

  test 'authenticated staff can consult new action form' do
    sign_in users(:staffuser)
    a = Aggregate.first
    get new_aggregate_action_path(a)
    assert_response :success
  end

  test 'authenticated staff can consult existent action form' do
    sign_in users(:staffuser)
    a = Action.first
    get edit_action_path(a)
    assert_response :success
  end

  test 'unauthenticated cannot consult new action form' do
    a = Aggregate.first
    get new_aggregate_action_path(a)
    check_not_authenticated
  end

  test 'unauthenticated cannot create new action' do
    a = Aggregate.first
    post '/actions', params:
      {
        act:
        {
          name: 'test',
          description: 'test',
          aggregate_ids: [a.id],
          state: 'ouverte',
          meta_state: 'active'
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can create new action' do
    sign_in users(:staffuser)
    a = Aggregate.first
    post '/actions', params:
      {
        act:
        {
          name: 'test',
          description: 'test',
          aggregate_ids: [a.id],
          state: 'ouverte',
          meta_state: 'active'
        }
      }
    updated_a = Action.find_by(name: 'test')
    assert_equal a.id, updated_a.aggregate.id
  end

  test 'authenticated staff cannot create new action without name' do
    sign_in users(:staffuser)
    a = Aggregate.first
    post "/aggregates/#{a.id}/actions", params:
      {
        act:
        {
          description: 'test',
          aggregate_ids: [a.id],
          state: 'ouverte',
          meta_state: 'active'
        }
      }
    assert_response(200)
  end

  test 'unauthenticated cannot delete action' do
    a = Action.first
    delete "/actions/#{a.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if an action exists trying to delete it' do
    delete '/actions/ABC'
    check_not_authenticated
  end

  test 'authenticated staff cannot delete non-existent action' do
    sign_in users(:staffuser)
    delete '/actions/ABC'
    assert_redirected_to actions_path
  end

  test 'authenticated staff can delete existent action' do
    a = Action.first
    sign_in users(:staffuser)
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    delete "/actions/#{a.id}"
    assert_raises ActiveRecord::RecordNotFound do
      a = Action.find(a.id)
    end
  end

  test 'unauthenticated cannot know if an action exists trying to restore it' do
    put '/actions/ABC/restore'
    check_not_authenticated
  end

  test 'unauthenticated cannot restore an deleted action' do
    a = Action.first
    sign_in users(:staffuser)
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    delete "/actions/#{a.id}"
    sign_out users(:staffuser)
    put "/actions/#{a.id}/restore"
    check_not_authenticated
  end

  test 'authenticated staff can restore a deleted action' do
    a = Action.first
    sign_in users(:staffuser)
    get action_path(a), headers: { 'HTTP_REFERER' => actions_path }
    delete "/actions/#{a.id}"
    put "/actions/#{a.id}/restore"
    resurec_a = Action.with_discarded.find(a.id)
    assert_equal resurec_a.id, a.id
  end

  test 'authenticated staff cannot restore non-existent action' do
    sign_in users(:staffuser)
    put '/actions/ABC/restore'
    check_unscoped(actions_path)
  end

  test 'authenticated staff cannot restore non-deleted action' do
    a = Action.first
    sign_in users(:staffuser)
    put "/actions/#{a.id}/restore"
    check_unscoped(actions_path)
  end

  test 'authenticated staff can comment action' do
    a = Action.first
    c = "Ceci n'est pas un commentaire"
    sign_in users(:staffuser)
    post_comment(a.id, c)
    assert_equal c, a.comments.order('created_at').first.comment
  end

  test 'authenticated staff cannot comment action if too short' do
    a = Action.first
    c = 'a'
    sign_in users(:staffuser)
    post_comment(a.id, c)
    assert_equal flash[:alert], I18n.t('comments.notices.length', locale: :fr)
  end

  test 'authenticated staff cannot comment action if too long' do
    a = Action.first
    c = 'a' * 1025
    sign_in users(:staffuser)
    post_comment(a.id, c)
    assert_equal flash[:alert], I18n.t('comments.notices.length', locale: :fr)
  end

  test 'unauthenticated cannot comment action' do
    a = Action.first
    c = "Ceci n'est pas un commentaire"
    post_comment(a.id, c)
    check_not_authenticated
  end

  test 'authenticated staff can delete multiple actions at once' do
    sign_in users(:staffuser)
    a = Action.first
    a2 = Action.last
    post '/actions/updates', params:
      {
        do: 'delete',
        choice: [a.id, a2.id]
      }
    assert_raises ActiveRecord::RecordNotFound do
      a = Action.find([a.id, a2.id])
    end
  end

  test 'unauthenticated cannot delete multiple actions at once' do
    post '/actions/updates', params:
      {
        do: 'delete',
        choice: Action.ids
      }
    check_not_authenticated
  end

  test 'authenticated staff can send mail' do
    sign_in users(:staffuser)
    a = Action.first
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'mail',
        choice: [a.id]
      }
    assert_equal I18n.t('actions.notices.mail_success'), flash[:notice]
  end

  test 'authenticated staff can send encrypted mail' do
    sign_in users(:staffuser)
    a = Action.first
    c = a.receiver
    c.public_key = "-----BEGIN PGP PUBLIC KEY BLOCK-----#{'A' * 3000}"
    c.public_key += '-----END PGP PUBLIC KEY BLOCK-----'
    c.save
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'mail',
        choice: [a.id]
      }
    assert_equal I18n.t('actions.notices.mail_success'), flash[:notice]
  end

  test 'authenticated staff cannot send mail with multiple recepients' do
    sign_in users(:staffuser)
    a = Action.first
    a2 = Action.where.not(receiver: a.receiver).first
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'mail',
        choice: [a.id, a2.id]
      }
    assert_equal I18n.t('actions.notices.receiver_error'), flash[:alert]
  end

  test 'authenticated staff cannot send mail without recepient' do
    sign_in users(:staffuser)
    a = Action.first
    a.receiver = nil
    a.save
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'mail',
        choice: [a.id]
      }
    assert_equal I18n.t('actions.notices.mail_fail'), flash[:alert]
  end

  test 'unauthenticated cannot send mail' do
    a = Action.first
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'mail',
        choice: [a.id]
      }
    check_not_authenticated
  end

  test 'authenticated staff can update multiple actions at once' do
    sign_in users(:staffuser)
    a = Action.first
    a2 = Action.last
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'assigned',
        choice: [a.id, a2.id]
      }
    assert Action.assigned.find([a.id, a2.id]).present?
  end

  test 'unauthenticated cannot update multiple actions at once' do
    a = Action.first
    a2 = Action.last
    post '/actions/updates', headers: { 'HTTP_REFERER' => actions_path }, params:
      {
        do: 'assigned',
        choice: [a.id, a2.id]
      }
    check_not_authenticated
  end

  private

  def filter_actions_by_name(name, prefix = '')
    sign_in users(:staffuser)
    # actions/archived_actions/clotured_actions
    get instance_eval("#{prefix}actions_path", __FILE__, __LINE__),
      params: { q: { name_cont: name } }
    assert_select 'main table.table' do
      assert_select 'td', text: "Action#{name}", count: 1
      assert_select 'td', text: 'Action1', count: 0
    end
  end

  def filter_by_equal_to(key, cou = 1)
    sign_in users(:staffuser)
    get actions_path, params: { q: { "#{key}_eq": '2' } }
    assert_select 'main table.table' do
      assert_select('td', text: 'Action3', count: cou) if cou == 1
      assert_select('td', text: 'Action1', count: cou)
      assert_select('td', text: 'Action2', count: cou) if cou.zero?
    end
  end

  def post_comment(action_id, comment)
    post "/actions/#{action_id}/comment", params:
      {
        comment:
        {
          comment: comment
        }
      }
  end
end
