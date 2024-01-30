# frozen_string_literal: true

class NotificationRefresher
  extend CableReady::Broadcaster

  NOTIF_LIST_SEL = '#notif_list'
  NOTIF_BTN_SEL = '#notif_btn'
  NOTIF_COUNTER_SEL = '#notif_counter'

  class << self
    # Prepend the new notification_subscription for user in #notif_list
    # Replace i_vibrate_h by i_vibrate class to #notif_btn
    # Update #notif_counter with new value
    # Send an in-browser native notification to be relayed through OS
    def append_new_notif_to_user_subs_list(user, notif)
      data = notif.data
      update_counter(user).remove_css_class(
        name: 'i_vibrate_h', selector: NOTIF_BTN_SEL
      ).add_css_class(
        name: 'i_vibrate', selector: NOTIF_BTN_SEL
      ).notification(
        title: data[:title],
        options: { body: data[:message] }
      ).prepend(
        selector: NOTIF_LIST_SEL,
        html: ApplicationController.render(
          partial: 'notifications/notification', locals: {
            notification_subscription: user.unread_notifications_subscriptions.first
          }
        )
      ).broadcast_to(user)
    end

    # Replace #notif_list content with last_created_first kept user.notifications_subscriptions
    # And update counter
    # This method complexity increases with number of notifications
    def refresh_user_subs_list(user)
      update_counter(user).inner_html(
        selector: NOTIF_LIST_SEL,
        html: ApplicationController.render(
          partial: 'notifications/list', locals: {
            notifs_subs: user.notifications_subscriptions.kept.last_created_first
          }
        )
      ).broadcast_to(user)
    end

    # Morph **notification_subscription** html content
    # and update counter
    # for specified user
    def refresh_user_sub(user, notification_subscription)
      update_counter(user).morph(
        selector: dom_id(notification_subscription),
        html: ApplicationController.render(
          partial: 'notifications/notification',
          locals: { notification_subscription: notification_subscription }
        )
      ).broadcast_to(user)
    end

    # Remove notification_subscription
    # and update counter
    # for specified user
    def remove_cleared_subscription(user, notification_subscription)
      update_counter(user).remove(
        selector: dom_id(notification_subscription)
      ).broadcast_to(user)
    end

    # update '#notif_counter' for user with user.unread_notifications_subscriptions.count
    # @return a cable_ready[UsersChannel] chainable object
    def update_counter(user)
      cable_ready[UsersChannel].text_content(
        selector: NOTIF_COUNTER_SEL, text: user.unread_notifications_subscriptions.count
      )
    end
  end
end
