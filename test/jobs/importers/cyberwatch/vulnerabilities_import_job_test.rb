# frozen_string_literal: true

require 'test_helper'

class Importers::Cyberwatch::VulnerabilitiesImportJobTest < ActiveJob::TestCase
  test 'Vulnerabilities are correctly imported through all' do
    test_import(last: false)
  end

  # test 'Vulnerabilities are correctly imported through last' do
  #   test_import(last: true)
  # end

  private

  def stub_it(check)
    proc do |_a0, _a1, _a2|
      if instance_eval(check, __FILE__, __LINE__)
        JSON.parse(File.read('test/fixtures/files/JobTestValues/Cyberwatch_Vulnerabilities.json'))
      else
        []
      end
    end
  end

  def asserts(prev, stub, last)
    ::Cyberwatch::Request.stub(:do_list, stub) do
      assert_equal ::Cyberwatch::Request.do_list(nil, nil, page: 0).class,
        Array
      if last
        assert_equal ::Cyberwatch::Request.do_list(nil, nil, page: 0,
          last_modified_after: Time.now.in_time_zone).class,
          Array
      else
        assert_equal ::Cyberwatch::Request.do_list(nil, nil, page: 1).class,
          Array
      end
      account = CyberwatchConfig.first
      # vuln_imports_count = account.vulnerabilities_imports.count
      Importers::Cyberwatch::VulnerabilitiesImportJob.perform_now(nil, account.id)
      assert_equal 11, Vulnerability.count - prev
      account.reload
      # assert_equal 1, account.vulnerabilities_imports.count - vuln_imports_count
    end
  end

  def test_import(last: false)
    prev = Vulnerability.count
    stub = last ? stub_it('_a2[:last_modified_after].present?') : stub_it('_a2[:page] < 1')
    asserts(prev, stub, last)
  end
end
