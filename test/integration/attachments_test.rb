# frozen_string_literal: true

require 'test_helper'

class AttachmentsTest < ActionDispatch::IntegrationTest
  # Related to Issue 182

  test 'Creating a new attachment does not delete previously attached object' do
    ReportExport.destroy_all

    50.times do
      r = ReportExport.create(report: Report.first, exporter: User.staffs.first)
      r.document.attach(io: File.open('test/fixtures/actions.yml'),
        filename: 'test',
        content_type: 'application/pdf')
    end

    assert_equal 50, ReportExport.all.map(&:document).pluck(:id).uniq.count
  end
end
