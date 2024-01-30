# frozen_string_literal: true

require 'test_helper'

class VulnerabilitiesImportsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot see imported vulnerabilities history' do
    get vulnerabilities_imports_path
    check_not_authenticated
  end

  test 'unauthenticated cannot access vulnerabilities import route' do
    get new_vulnerabilities_import_path
    check_not_authenticated
  end

  test 'unauthenticated cannot import vulnerabilities' do
    file = fixture_file_upload('JobTestValues/nvdcve-1.1-2013.json', 'application/json')
    post vulnerabilities_import_path, params: {
      vulnerability_import: {
        import_type: 0,
        document: file
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot delete imported vulnerability' do
    import = VulnerabilityImport.first
    delete "#{vulnerabilities_import_path}/#{import.id}"
    check_not_authenticated
  end

  test 'authenticated staff superadmin only can see imported vulnerabilities history' do
    sign_in users(:staffuser)
    get vulnerabilities_imports_path
    check_not_authorized
    sign_in users(:superadmin)
    get vulnerabilities_imports_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can access vulnerabilities import route' do
    sign_in users(:staffuser)
    get new_vulnerabilities_import_path
    check_not_authorized
    sign_in users(:superadmin)
    get new_vulnerabilities_import_path
    assert_response :success
  end

  test 'authenticated staff superadmin only can import nist cve vulnerabilities' do
    sign_in users(:staffuser)
    file = fixture_file_upload('JobTestValues/nvdcve-1.1-2013.json', 'application/json')
    post vulnerabilities_import_path, params: {
      vulnerability_import: {
        import_type: 0,
        document: file
      }
    }
    check_not_authorized
    sign_in users(:superadmin)
    post vulnerabilities_import_path, params: {
      vulnerability_import: {
        import_type: 0,
        document: file
      }
    }
    assert_redirected_to :vulnerabilities
    assert_equal I18n.t('imports.notices.processing'), flash[:notice]
  end

  test 'authenticated staff superadmin only can delete imported vulnerabilities' do
    sign_in users(:staffuser)
    import = vulnerability_imports(:vuln_import_one)
    delete "#{vulnerabilities_import_path}/#{import.id}"
    check_unscoped('/vulnerabilities')
    sign_in users(:superadmin)
    delete "#{vulnerabilities_import_path}/#{import.id}"
    assert_redirected_to :vulnerabilities
  end

  test 'authenticated staff superadmin only cannot delete imported vulnerabilities if used' do
    sign_in users(:staffuser)
    import = vulnerability_imports(:vuln_import_two)
    delete "#{vulnerabilities_import_path}/#{import.id}"
    check_unscoped('/vulnerabilities')
    sign_in users(:superadmin)
    delete "#{vulnerabilities_import_path}/#{import.id}"
    check_not_authorized
  end
end
