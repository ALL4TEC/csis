# frozen_string_literal: true

require 'test_helper'
require 'utils/tmp_file_helper'

module Generators
  class ScanReportGeneratorJobTest < ActiveJob::TestCase
    include TmpFileHelper

    test 'that column_number function of type is good' do
      generator = ScanReportGeneratorJob.new
      assert_equal(4, generator.send(:columns_nb, :system))
      assert_equal(5, generator.send(:columns_nb, :applicative))
    end

    # Testing job
    test 'that scan report generation is performed in french' do
      test_scan_report_generation
    end

    test 'that scan report generation is performed in english' do
      test_scan_report_generation(:en)
    end

    test 'that scan report generation is performed with diff with previous report' do
      rep_exp = report_exports(:report_export_three)
      ScanReportGeneratorJob.perform_now(rep_exp.id, true, true)
      assert(rep_exp.document.attached?, 'No file generated!')
    end

    private

    def test_scan_report_generation(lang = :fr)
      rep_exp = report_exports(:report_export_one)
      rep = rep_exp.report
      rep.language = Language.find_by(iso: lang)
      rep.save
      ScanReportGeneratorJob.perform_now(rep_exp.id, false, false)
      assert(rep_exp.document.attached?, 'No file generated!')
    end
  end
end
