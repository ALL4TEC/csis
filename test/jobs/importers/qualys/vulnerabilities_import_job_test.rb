# frozen_string_literal: true

require 'test_helper'

class Importers::Qualys::VulnerabilitiesImportJobTest < ActiveJob::TestCase
  test 'All vulnerabilities are correctly imported' do
    test_import
  end

  test 'Last vulnerabilities are correctly imported' do
    test_import(true)
  end

  private

  def stub_it(check, file = 'Vulnerability')
    proc do |_a0, _a1, _a2, _a3, _a4|
      if instance_eval(check, __FILE__, __LINE__)
        YAML.safe_load_file(
          "test/fixtures/files/JobTestValues/Qualys_#{file}.txt",
          permitted_classes: [
            ::Qualys::ListResponse,
            ::Qualys::Vulnerability,
            ActiveSupport::TimeWithZone,
            Time,
            ActiveSupport::TimeZone,
            ::Qualys::ExploitSource,
            ::Qualys::Exploit
          ],
          permitted_symbols: [],
          aliases: true
        ) # Authorize aliases
      else
        ::Qualys::ListResponse.new([], nil)
      end
    end
  end

  def step_one(last = false)
    account = QualysConfig.first
    vuln_imports_count = account.vulnerabilities_imports.count
    stub = stub_it('_a4[:id_min] < 50_000')
    ::Qualys::Request.stub(:do_list, stub) do
      assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
        action: nil,
        id_min: 0,
        id_max: nil).class,
        ::Qualys::ListResponse
      assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
        action: nil,
        id_min: 50_000,
        id_max: nil).class,
        ::Qualys::ListResponse

      # GIVEN
      # A QualysConfig account
      # No vulnerability in db
      Vulnerability.all.map(&:destroy)
      assert Vulnerability.count.zero?
      # WHEN performing import
      Importers::Qualys::VulnerabilitiesImportJob.perform_now(
        nil, account.id, last: last
      )
      # THEN
      # One new vulnerability_import have been created
      account.reload
      assert_equal 1, account.vulnerabilities_imports.count - vuln_imports_count
      # 5 new vulnerabilities have been imported
      assert_equal 5, Vulnerability.count
    end
  end

  def step_two(last = false)
    account = QualysConfig.first
    vuln_imports_count = account.vulnerabilities_imports.count
    stub = last ? stub_it('_a4[:last_modified_after].present?') : stub_it('_a4[:id_min] < 50_000')
    ::Qualys::Request.stub(:do_list, stub) do
      assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
        action: nil,
        id_min: 0,
        id_max: nil).class,
        ::Qualys::ListResponse
      if last
        assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
          action: nil,
          last_modified_after: Time.now.in_time_zone).class,
          ::Qualys::ListResponse
      else
        assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
          action: nil,
          id_min: 50_000,
          id_max: nil).class,
          ::Qualys::ListResponse
      end

      # GIVEN
      # same qualys account
      # 5 existing vulnerabilities
      existing_vulnerabilities = Vulnerability.all.map { |vuln| [vuln.id, vuln.updated_at] }

      # WHEN
      # importing same vulnerabilities without any modification
      Importers::Qualys::VulnerabilitiesImportJob.perform_now(
        nil, account.id, last: last
      )

      # THEN
      # No new vulnerability is added
      assert_equal 1, account.vulnerabilities_imports.count - vuln_imports_count
      assert_equal 2, account.vulnerabilities_imports.count
      assert account.vulnerabilities_imports.order('created_at desc').first.vulnerabilities.count
                    .zero?
      assert_equal 5, Vulnerability.count
      # And existing ones are not updated
      existing_vulnerabilities.each do |vuln|
        # reload vuln
        vulnerability = Vulnerability.find(vuln[0])
        assert_equal vuln[1], vulnerability.updated_at
      end
    end
  end

  def step_three(last = false)
    account = QualysConfig.first
    vuln_imports_count = account.vulnerabilities_imports.count
    stub = if last
             stub_it('_a4[:last_modified_after].present?', 'Vulnerability_2')
           else
             stub_it('_a4[:id_min] < 50_000', 'Vulnerability_2')
           end
    ::Qualys::Request.stub(:do_list, stub) do
      assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
        action: nil,
        id_min: 0,
        id_max: nil).class,
        ::Qualys::ListResponse
      if last
        assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
          action: nil,
          last_modified_after: Time.now.in_time_zone).class,
          ::Qualys::ListResponse
      else
        assert_equal ::Qualys::Request.do_list(nil, nil, nil, nil,
          action: nil,
          id_min: 50_000,
          id_max: nil).class,
          ::Qualys::ListResponse
      end

      # GIVEN
      # same qualys account
      # 5 existing vulnerabilities

      # WHEN
      # importing same vulnerabilities
      # except one modified after last_modified existing
      # And one new
      # without last only
      Importers::Qualys::VulnerabilitiesImportJob.perform_now(
        nil, account.id, last: last
      )

      # THEN
      # A vulnerabilityImport is created
      # existing are not updated except modified one (qid: 16)
      # New vulnerability is added (qid: 1600)
      assert_equal 1, account.vulnerabilities_imports.count - vuln_imports_count
      assert_equal 3, account.vulnerabilities_imports.count
      assert_equal 2, account.vulnerabilities_imports.order('created_at desc').first
                             .vulnerabilities.count
      assert_equal 6, Vulnerability.count
      modified_vuln = Vulnerability.find_by(qid: 16)
      assert_equal(
        DateTime.parse('Thu, 02 Jan 2020 18:39:37.000000000 CET +01:00'), modified_vuln.modified
      )
      added_vuln = Vulnerability.find_by(qid: 1600)
      assert added_vuln.present?
    end
  end

  def test_import(last = false)
    step_one(last)
    step_two(last)
    step_three(last)
  end
end
