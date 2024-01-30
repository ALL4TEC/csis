# frozen_string_literal: true

require 'test_helper'

class VmOccurrenceTest < ActiveSupport::TestCase
  test 'that related notifications are cleared when deleting a vm occurrence' do
    # GIVEN
    # A vm occurrence
    # 1 notification related to previous
    vm_occurrence = VmOccurrence.create!(
      scan: VmScan.first,
      vulnerability: Vulnerability.first
    )
    Notification.create!(
      version: vm_occurrence.versions.last,
      subscribers: [],
      subject: :exceeding_severity_threshold
    )
    assert Notification.where(version_id: vm_occurrence.versions).count.positive?
    # WHEN
    # Deleting
    vm_occurrence.destroy!
    # THEN
    # Notification is also destroyed
    assert Notification.where(version_id: vm_occurrence.versions).count.zero?
  end
end
