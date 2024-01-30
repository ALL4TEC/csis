# frozen_string_literal: true

module Users
  class ProfileParamsHandler
    attr_reader :permitted

    def initialize(permitted)
      @permitted = permitted
    end

    def self.call(permitted)
      new(permitted).handle
    end

    def handle
      send_mail_on_p = permitted['send_mail_on']
      all_send_mail_on_in = all_allowed?(send_mail_on_p.compact_blank)
      notify_on_p = permitted['notify_on']
      all_notify_on_in = all_allowed?(notify_on_p.compact_blank)
      dirty = [notify_on_p, send_mail_on_p].any?(&:present?)
      valid = [all_send_mail_on_in, all_notify_on_in].all?(true)
      dirty & valid
    end

    # Check all params keys are in Notification.subjects.keys
    def all_allowed?(param)
      all_allowed = true
      if param.present?
        all_allowed = param.all? do |subject|
          NotificationService.subject_allowed?(subject)
        end
      end
      all_allowed
    end
  end
end
