# frozen_string_literal: true

class NotificationPredicate
  class << self
    def linked_to_nil_version?(notif)
      notif.version.nil?
    end

    def imported_scan_linked_to_nil_report?(notif)
      (notif.item.is_a?(VmScan) || notif.item.is_a?(WaScan)) &&
        notif.item.scan_import&.report_scan_import&.report.nil?
    end

    def launched_scan_linked_to_nil_report?(notif)
      notif.item.is_a?(ScanLaunch) && notif.item.report.nil?
    end
  end
end
