# frozen_string_literal: true

require 'test_helper'

class QualysClientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list qualys vm clients' do
    get qualys_vm_clients_path
    check_not_authenticated
  end

  test 'authenticated cyberanalyst cannot list qualys vm clients' do
    sign_in users(:cyberanalyst)
    get qualys_vm_clients_path
    assert_redirected_to root_path
  end

  test 'authenticated superadmin can list qualys vm clients' do
    sign_in users(:superadmin)
    get qualys_vm_clients_path
    assert_response :success
  end

  test 'unauthenticated cannot list qualys wa clients' do
    get qualys_wa_clients_path
    check_not_authenticated
  end

  test 'authenticated cyberanalyst cannot list qualys wa clients' do
    sign_in users(:cyberanalyst)
    get qualys_wa_clients_path
    assert_redirected_to root_path
  end

  test 'authenticated superadmin can list qualys wa clients' do
    sign_in users(:superadmin)
    get qualys_wa_clients_path
    assert_response :success
  end

  # Index n'est pas utilisé et à une erreur dans les headers

  # test 'unauthenticated cannot list vm clients for qualys config' do
  #   get qualys_config_qualys_vm_clients_path(QualysConfig.first)
  #   check_not_authenticated
  # end

  # test 'authenticated can list vm clients for qualys config' do
  #   sign_in users(:superadmin)
  #   get qualys_config_qualys_vm_clients_path(QualysConfig.first)
  #   assert_response :success
  # end

  # test 'unauthenticated cannot list wa clients for qualys config' do
  #   get qualys_config_qualys_wa_clients_path(QualysConfig.first)
  #   check_not_authenticated
  # end

  # test 'authenticated can list wa clients for qualys config' do
  #   sign_in users(:superadmin)
  #   get qualys_config_qualys_wa_clients_path(QualysConfig.first)
  #   assert_response :success
  # end
end
