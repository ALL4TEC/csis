# frozen_string_literal: true

# Service which aim is to destroy old and linked to a nil version notifications
class Cleaners::NotificationCleaner
  class << self
    def clear_all
      clear_old
      clear_linked_to_nil_version
      clear_linked_to_nil_report
    end

    def clear_old
      Notification.old.destroy_all
    end

    def clear_linked_to_nil_version
      Notification.all.select(&NotificationLambda.linked_to_nil_version).each(&:destroy)
    end

    def clear_linked_to_nil_report
      # rubocop:disable Layout/LineLength
      Notification.all.select(&NotificationLambda.launched_scan_linked_to_nil_report).each(&:destroy)
      Notification.all.select(&NotificationLambda.imported_scan_linked_to_nil_report).each(&:destroy)
      # rubocop:enable Layout/LineLength
    end
  end
end
