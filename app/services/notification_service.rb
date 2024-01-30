# frozen_string_literal: true

class NotificationService
  class << self
    # rubocop:disable Rails/SkipsModelValidations
    # @param **user:** The user to mark all notifications_subscriptions as read
    def read_all(user)
      user.notifications_subscriptions.update_all(state: :read)
    end

    # @param **user:** The user to mark all notifications_subscriptions as not_read
    def unread_all(user)
      user.notifications_subscriptions.update_all(state: :unread)
    end
    # rubocop:enable Rails/SkipsModelValidations

    # @param **user:** The user to discard all notifications_subscriptions
    def clear_all(user)
      user.notifications_subscriptions.discard_all
    end

    # @param **user:** The user to undiscard all notifications_subscriptions
    def restore_all(user)
      user.notifications_subscriptions.with_discarded.undiscard_all
    end

    # @param **subject:** The notification subject to check
    # @return subject.in?(Notification.subjects.keys)
    def subject_allowed?(subject)
      subject.to_s.in?(Notification.subjects.keys)
    end

    # Destroy all notifications with a version linked to object
    # @param **object:** The deleted object to clear related notifications
    def clear_related_to(object)
      # Look for PaperTrail::Version where item: object
      related_versions = object.versions
      # Look for Notification.where(version_id: versions)
      Notification.where(version_id: related_versions).destroy_all
    end
  end
end
