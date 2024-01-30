# frozen_string_literal: true

require 'test_helper'

class VulnerabilitiesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list vulnerabilities' do
    get vulnerabilities_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list burp vulnerabilities' do
    get burp_vulnerabilities_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list cve vulnerabilities' do
    get cve_vulnerabilities_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list qualys vulnerabilities' do
    get qualys_vulnerabilities_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list nessus vulnerabilities' do
    get nessus_vulnerabilities_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list zaproxy vulnerabilities' do
    get zaproxy_vulnerabilities_path
    check_not_authenticated
  end

  test 'unauthenticated cannot consult vulnerabilities' do
    vuln = Vulnerability.first
    get "/vulnerabilities/#{vuln.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if a vulnerability exists' do
    get '/vulnerabilities/ABC'
    check_not_authenticated
  end

  test 'authenticated staff can list vulnerabilities' do
    sign_in users(:staffuser)
    get vulnerabilities_path
    assert_select 'main table.table' do
      Vulnerability.page(1).each do |vuln|
        assert_select 'a', text: vuln.qid.to_s
        assert_select 'a', text: vuln.title
      end
    end
  end

  test 'authenticated staff can filter vulnerabilities by title containing' do
    sign_in users(:staffuser)
    get vulnerabilities_path, params: { q: { title_cont: 'Double-free' } }
    assert_select 'main table.table' do
      vuln = Vulnerability.find_by(qid: 316_208)
      assert_select 'a', text: vuln.qid.to_s
      assert_select 'a', text: vuln.title
    end
  end

  test 'authenticated staff can filter vulnerabilities by kind equal to' do
    sign_in users(:staffuser)
    get vulnerabilities_path, params: { q: { kind_eq: '' } }
    assert_select 'main table.table' do
      vuln = Vulnerability.find_by(qid: 316_208)
      assert_select 'a', text: vuln.qid.to_s
      assert_select 'a', text: vuln.title
    end
  end

  test 'authenticated staff can filter vulnerabilities by severity equal to' do
    sign_in users(:staffuser)
    get vulnerabilities_path, params: { q: { severity_eq: '' } }
    assert_select 'main table.table' do
      vuln = Vulnerability.find_by(qid: 316_208)
      assert_select 'a', text: vuln.qid.to_s
      assert_select 'a', text: vuln.title
    end
  end

  test 'authenticated staff can filter vulnerabilities by qid equal to' do
    sign_in users(:staffuser)
    get vulnerabilities_path, params: { q: { qid_eq: '' } }
    assert_select 'main table.table' do
      vuln = Vulnerability.find_by(qid: 316_208)
      assert_select 'a', text: vuln.qid.to_s
      assert_select 'a', text: vuln.title
    end
  end

  test 'authenticated staff can list burp vulnerabilities' do
    sign_in users(:staffuser)
    get burp_vulnerabilities_path
    assert_select 'main table.table' do
      Vulnerability.burp_kb_type.page(1).each do |vuln|
        assert_select 'a', text: vuln.qid.to_s
        assert_select 'a', text: vuln.title
      end
    end
  end

  test 'authenticated staff can list cve vulnerabilities' do
    sign_in users(:staffuser)
    get cve_vulnerabilities_path
    assert_select 'main table.table' do
      Vulnerability.cve_kb_type.page(1).each do |vuln|
        assert_select 'a', text: vuln.qid.to_s
        assert_select 'a', text: vuln.title
      end
    end
  end

  test 'authenticated staff can list qualys vulnerabilities' do
    sign_in users(:staffuser)
    get qualys_vulnerabilities_path
    assert_select 'main table.table' do
      Vulnerability.qualys_kb_type.page(1).each do |vuln|
        assert_select 'a', text: vuln.qid.to_s
        assert_select 'a', text: vuln.title
      end
    end
  end

  test 'authenticated staff can list nessus vulnerabilities' do
    sign_in users(:staffuser)
    get nessus_vulnerabilities_path
    assert_select 'main table.table' do
      Vulnerability.nessus_kb_type.page(1).each do |vuln|
        assert_select 'a', text: vuln.qid.to_s
        assert_select 'a', text: vuln.title
      end
    end
  end

  test 'authenticated staff can list zaproxy vulnerabilities' do
    sign_in users(:staffuser)
    get zaproxy_vulnerabilities_path
    assert_select 'main table.table' do
      Vulnerability.zaproxy_kb_type.page(1).each do |vuln|
        assert_select 'a', text: vuln.qid.to_s
        assert_select 'a', text: vuln.title
      end
    end
  end

  test 'authenticated staff can view vulnerability' do
    sign_in users(:staffuser)
    vuln = Vulnerability.first
    get "/vulnerabilities/#{vuln.id}"
    assert_select 'h5 span', text: vuln.title
  end

  test 'authenticated staff cannot consult inexistant vulnerability' do
    sign_in users(:staffuser)
    get '/vulnerabilities/ABC'
    assert_redirected_to vulnerabilities_path
  end

  test 'unauthenticated staff cannot consult vulnerability' do
    vuln = Vulnerability.first
    get "/vulnerabilities/#{vuln.id}"
    check_not_authenticated
  end

  test 'unauthenticated staff cannot list vulnerabilities imports' do
    get vulnerabilities_imports_path
    check_not_authenticated
  end

  test 'authenticated staff can list vulnerabilities imports' do
    sign_in users(:staffuser)
    get vulnerabilities_imports_path
    assert_response 302
  end

  test 'unauthenticated staff cannot import new vulnerabilities' do
    get new_vulnerabilities_import_path
    check_not_authenticated
  end

  test 'authenticated staff can import new vulnerabilities' do
    sign_in users(:staffuser)
    get new_vulnerabilities_import_path
    assert_response 302
  end
end
