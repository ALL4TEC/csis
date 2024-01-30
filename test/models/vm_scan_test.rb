# frozen_string_literal: true

require 'test_helper'

class VmScanTest < ActiveSupport::TestCase
  test 'that related notifications are cleared when deleting a vm scan' do
    # GIVEN
    # A vm scan
    # 1 notification related to previous
    vm_scan = VmScan.create!(
      reference: '12345',
      scan_type: 'scheduled',
      launched_at: Time.zone.now,
      name: 'some scan',
      status: 'FINISHED',
      duration: '00:11:11'
    )
    assert Notification.where(version_id: vm_scan.versions).count.positive?
    # WHEN
    # Deleting
    vm_scan.destroy!
    # THEN
    # Notification is also destroyed, but a last one is created for scan deletion
    assert_equal 1, Notification.where(version_id: vm_scan.versions).count
  end
end
