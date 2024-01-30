# frozen_string_literal: true

require 'test_helper'

class WaScanTest < ActiveSupport::TestCase
  test 'that related notifications are cleared when deleting a wa scan' do
    # GIVEN
    # A wa scan
    # 1 notification related to previous
    wa_scan = WaScan.create!(
      reference: '12345',
      scan_type: 'scheduled',
      launched_at: Time.zone.now,
      name: 'some scan',
      status: 'FINISHED'
    )
    assert Notification.where(version_id: wa_scan.versions).count.positive?
    # WHEN
    # Deleting
    wa_scan.destroy!
    # THEN
    # Notification is also destroyed, but a last one is created for scan deletion
    assert_equal 1, Notification.where(version_id: wa_scan.versions).count
  end
end
