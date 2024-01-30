# frozen_string_literal: true

require 'test_helper'

class Importers::CveImportJobTest < ActiveJob::TestCase
  test 'CVE are correctly imported' do
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/nvdcve-1.1-2013.json'),
      filename: 'nvdcve-1.1-2013.json',
      content_type: 'application/json',
      identify: false
    }
    vuln_import = VulnerabilityImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :cve,
      document: attachment
    )
    Importers::CveImportJob.perform_now(vuln_import)
    assert_equal 'completed', vuln_import.status
  end

  test 'CVE import in error is correctly handled' do
    attachment = {
      io: File.open('test/fixtures/files/JobTestValues/burp_issues.xml'),
      filename: 'burp_issues.xml',
      content_type: 'application/xml',
      identify: false
    }
    vuln_import = VulnerabilityImport.create!(
      importer: users(:staffuser), status: :scheduled, import_type: :cve,
      document: attachment
    )
    Importers::CveImportJob.perform_now(vuln_import)
    assert_equal 'failed', vuln_import.status
  end

  test 'CVE import correctly update existing vulnerability' do
    # TODO
    assert true
  end
end
