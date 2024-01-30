# frozen_string_literal: true

require 'test_helper'

class AuditLogControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see audit logs ' do
    get audit_logs_path
    check_not_authenticated
  end

  test 'authenticated superadmin only can see audit logs' do
    sign_in users(:superadmin)
    get '/audit_logs'
    assert_response 200
  end

  test 'authenticated superadmin can filter audit_logs by range' do
    sign_in users(:superadmin)
    get '/audit_logs?q%5Bwhodunnit_cont%5D=&q%5Bitem_type_cont%5D=&q%5Bevent_cont%5D=' \
        '&q%5Bstart_range%5D=2021-01-01&q%5Bend_range%5D=2021-02-01' \
        '&commit=Rechercher'
    assert_response 200
  end

  test 'authenticated superadmin can filter audit_logs by model' do
    sign_in users(:superadmin)
    get '/audit_logs?q%5Bwhodunnit_cont%5D=&q%5Bitem_type_cont%5D=Role&q%5Bevent_cont%5D=' \
        'commit=Rechercher'
    assert_response 200
  end

  test 'authenticated superadmin can filter audit_logs by user' do
    sign_in users(:superadmin)
    get '/audit_logs?q%5Bwhodunnit_cont%5D=382e5a27-4b28-4f9c-91b0-81eee0828ea3&q%5B' \
        'item_type_cont%5D=&q%5Bevent_cont%5D=&commit=Rechercher'
    assert_response 200
  end

  test 'authenticated superadmin can filter audit_logs by action' do
    sign_in users(:superadmin)
    get '/audit_logs?q%5Bwhodunnit_cont%5D=&q%5Bitem_type_cont%5D=&q%5Bevent_cont%5D=create&' \
        'commit=Rechercher'
    assert_response 200
  end
end
