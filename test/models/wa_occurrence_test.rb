# frozen_string_literal: true

require 'test_helper'

class WaOccurrenceTest < ActiveSupport::TestCase
  test 'that related notifications are cleared when deleting a wa occurrence' do
    # GIVEN
    # A wa occurrence
    # 1 notification related to previous
    wa_occurrence = WaOccurrence.create!(
      scan: WaScan.first,
      vulnerability: Vulnerability.first
    )
    Notification.create!(
      version: wa_occurrence.versions.last,
      subscribers: [],
      subject: :exceeding_severity_threshold
    )
    assert Notification.where(version_id: wa_occurrence.versions).count.positive?
    # WHEN
    # Deleting
    wa_occurrence.destroy!
    # THEN
    # Notification is also destroyed
    assert Notification.where(version_id: wa_occurrence.versions).count.zero?
  end
end
