# frozen_string_literal: true

require 'test_helper'

class DashboardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot toggle default view' do
    switch_default_card('vulnerabilities')
    check_not_authenticated
  end

  test 'authenticated staff can toggle vulnerabilities occurencies as default card' do
    user = users(:staffuser)
    sign_in user
    switch_default_card('vulnerabilities', true, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated staff can view vulnerabilities occurencies' do
    user = users(:staffuser)
    sign_in user
    get dashboard_vulnerabilities_path, xhr: true
    assert_response :success
  end

  test 'authenticated contact cannot toggle vulnerabilities occurencies as default card' do
    user = users(:c_one)
    sign_in user
    switch_default_card('vulnerabilities', false, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated contact cannot view vulnerabilities occurencies' do
    user = users(:c_one)
    sign_in user
    get dashboard_vulnerabilities_path, xhr: true
    check_not_authorized
  end

  test 'authenticated staff can toggle last reports as default card' do
    user = users(:staffuser)
    sign_in user
    # As reports is default card, we must set another one before switching, else it toggles off
    switch_default_card('wa-scans', true, user)
    switch_default_card('reports', true, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated staff can view last reports' do
    user = users(:staffuser)
    sign_in user
    get dashboard_last_reports_path, xhr: true
    assert_response :success
  end

  test 'authenticated contact can toggle last reports as default card' do
    user = users(:c_one)
    sign_in user
    # As reports is default card, we must set another one before switching, else it toggles off
    switch_default_card('actions', true, user)
    switch_default_card('reports', true, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated contact can view last reports' do
    user = users(:c_one)
    sign_in user
    get dashboard_last_reports_path, xhr: true
    assert_response :success
  end

  test 'authenticated staff can toggle last wa scans as default card' do
    user = users(:staffuser)
    sign_in user
    switch_default_card('wa-scans', true, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated staff can view last wa scans' do
    user = users(:staffuser)
    sign_in user
    get dashboard_last_wa_scans_path, xhr: true
    assert_response :success
  end

  test 'authenticated contact cannot toggle last wa scans as default card' do
    user = users(:c_one)
    sign_in user
    switch_default_card('wa-scans', false, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated contact cannot view last wa scans' do
    user = users(:c_one)
    sign_in user
    get dashboard_last_wa_scans_path, xhr: true
    check_not_authorized
  end

  test 'authenticated staff can toggle last vm scans as default card' do
    user = users(:staffuser)
    sign_in user
    switch_default_card('vm-scans', true, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated staff can view last vm scans' do
    user = users(:staffuser)
    sign_in user
    get dashboard_last_vm_scans_path, xhr: true
    assert_response :success
  end

  test 'authenticated contact cannot toggle last vm scans as default card' do
    user = users(:c_one)
    sign_in user
    switch_default_card('vm-scans', false, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated contact cannot view last vm scans' do
    user = users(:c_one)
    sign_in user
    get dashboard_last_vm_scans_path, xhr: true
    check_not_authorized
  end

  test 'authenticated contact can toggle last active actions as default card' do
    user = users(:c_one)
    sign_in user
    switch_default_card('actions', true, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated contact can view last active actions' do
    user = users(:c_one)
    sign_in user
    get dashboard_last_active_actions_path, xhr: true
    assert_response :success
  end

  test 'authenticated staff cannot toggle last active actions as default card' do
    user = users(:staffuser)
    sign_in user
    switch_default_card('actions', false, user)
    assert_redirected_to dashboard_path
    get dashboard_path
    assert_response :success
  end

  test 'authenticated staff cannot view last active actions' do
    user = users(:staffuser)
    sign_in user
    get dashboard_last_active_actions_path, xhr: true
    check_not_authorized
  end

  private

  def switch_default_card(view, check = nil, user = nil)
    post dashboard_default_card_path, params: { view: view }
    return if check.blank?

    user.reload
    assert_equal(user.current_dashboard_default_card == view, check)
  end
end
