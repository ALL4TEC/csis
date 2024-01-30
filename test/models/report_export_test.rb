# frozen_string_literal: true

require 'test_helper'

class ReportExportTest < ActiveSupport::TestCase
  test 'that related notifications are cleared when deleting a report export' do
    # GIVEN
    # A report export
    # 1 notification related to previous
    export = ReportExport.create!(report: Report.first, exporter: users(:samuel))
    export.update(status: :generated)
    assert Notification.where(version_id: export.versions).count.positive?
    # WHEN
    # Deleting report export
    export.destroy!
    # THEN
    # Notification is also destroyed
    assert Notification.where(version_id: export.versions).count.zero?
  end
end
