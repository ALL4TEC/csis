# frozen_string_literal: true

module DeviseConcern
  extend ActiveSupport::Concern

  included do
    after_commit :send_pending_devise_notifications

    protected

    def send_devise_notification(notification, *args)
      # If the record is new or changed then delay the
      # delivery until the after_commit callback otherwise
      # send now because after_commit will not be called.
      # For Rails < 6 use `changed?` instead of `saved_changes?`.
      if new_record? || changed?
        pending_devise_notifications << [notification, args]
      else
        render_and_send_devise_message(notification, *args)
      end
    end

    private

    def send_pending_devise_notifications
      pending_devise_notifications.each do |notification, args|
        render_and_send_devise_message(notification, *args)
      end

      # Empty the pending notifications array because the
      # after_commit hook can be called multiple times which
      # could cause multiple emails to be sent.
      pending_devise_notifications.clear
    end

    def pending_devise_notifications
      @pending_devise_notifications ||= []
    end

    def render_and_send_devise_message(notification, *)
      message = devise_mailer.send(notification, self, *)

      # Deliver later with Active Job's `deliver_later`
      if message.respond_to?(:deliver_later)
        message.deliver_later
      else
        message.deliver_now
      end
    end
  end
end
