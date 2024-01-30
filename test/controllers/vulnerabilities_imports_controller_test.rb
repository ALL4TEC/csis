# frozen_string_literal: true

require 'test_helper'

class VulnerabilitiesImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot view vulnerabilities imports page' do
    get vulnerabilities_imports_path
    check_not_authenticated
  end

  test 'authenticated cyber_analyst cannot view vulnerabilities imports page' do
    sign_in users(:cyberanalyst)
    get vulnerabilities_imports_path
    assert_redirected_to root_path
  end

  test 'authenticated super_admin can view vulnerabilities imports page' do
    sign_in users(:superadmin)
    get vulnerabilities_imports_path
    assert_response :success
  end

  test 'unauthenticated cannot view new vulnerabilities import form' do
    get new_vulnerabilities_import_path
    check_not_authenticated
  end

  test 'authenticated cyber_analyst cannot view new vulnerabilities import form' do
    sign_in users(:cyberanalyst)
    get new_vulnerabilities_import_path
    assert_redirected_to root_path
  end

  test 'authenticated super_admin can view new vulnerabilities import form' do
    sign_in users(:superadmin)
    get new_vulnerabilities_import_path
    assert_response :success
  end

  test 'unauthenticated cannot import new vulnerabilities' do
    post vulnerabilities_import_path
    check_not_authenticated
  end

  test 'authenticated cyber_analyst cannot import new vulnerabilities' do
    sign_in users(:cyberanalyst)
    post vulnerabilities_import_path, params: {
      vulnerability_import: {
        import_type: 'cve',
        document: fixture_file_upload('JobTestValues/nvdcve-1.1-2013.json', json_mime)
      }
    }
    assert_redirected_to root_path
  end

  test 'authenticated super_admin can import new vulnerabilities' do
    sign_in users(:superadmin)
    post vulnerabilities_import_path, params: {
      vulnerability_import: {
        import_type: 'cve',
        document: fixture_file_upload('JobTestValues/nvdcve-1.1-2013.json', json_mime)
      }
    }
    assert_equal I18n.t('imports.notices.processing'), flash[:notice]
  end

  test 'unauthenticated cannot delete vulnerabilities import' do
    delete "/imports/vulnerabilities/#{VulnerabilityImport.first.id}"
    check_not_authenticated
  end

  test 'authenticated cyber_analyst cannot delete vulnerabilities import' do
    sign_in users(:cyberanalyst)
    delete "/imports/vulnerabilities/#{VulnerabilityImport.first.id}"
    assert_equal I18n.t('activerecord.errors.not_found'), flash[:alert]
  end

  test 'authenticated super_admin can delete vulnerabilities import' do
    sign_in users(:superadmin)
    delete "/imports/vulnerabilities/#{VulnerabilityImport.first.id}"
    assert_equal I18n.t('imports.notices.deleted'), flash[:notice]
  end
end
