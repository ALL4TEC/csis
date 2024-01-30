# frozen_string_literal: true

class NotificationLambda
  class << self
    def linked_to_nil_version
      ->(notif) { NotificationPredicate.linked_to_nil_version?(notif) }
    end

    def imported_scan_linked_to_nil_report
      ->(notif) { NotificationPredicate.imported_scan_linked_to_nil_report?(notif) }
    end

    def launched_scan_linked_to_nil_report
      ->(notif) { NotificationPredicate.launched_scan_linked_to_nil_report?(notif) }
    end
  end
end
