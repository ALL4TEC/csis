# frozen_string_literal: true

class NotificationReflex < ApplicationReflex
  # before_reflex :authenticate_user!, Useless as authentication is handled in
  # ApplicationCable::Channel
  # No authorization needed as actions are available for all connected users
  # And we just have to handle scope
  before_reflex :set_notification_subscription, only: %i[toggle_state clear]

  def toggle_state
    next_state = @notification_subscription.read? ? :unread : :read
    @notification_subscription.update(state: next_state)
    NotificationRefresher.refresh_user_sub(current_user, @notification_subscription)
    morph :nothing
  end

  def clear
    @notification_subscription.discard
    NotificationRefresher.remove_cleared_subscription(current_user, @notification_subscription)
    morph :nothing
  end

  def clear_all
    NotificationService.clear_all(current_user)
    NotificationRefresher.refresh_user_subs_list(current_user)
    morph :nothing
  end

  def restore_all
    NotificationService.restore_all(current_user)
    NotificationRefresher.refresh_user_subs_list(current_user)
    morph :nothing
  end

  def read_all
    NotificationService.read_all(current_user)
    NotificationRefresher.refresh_user_subs_list(current_user)
    morph :nothing
  end

  def unread_all
    NotificationService.unread_all(current_user)
    NotificationRefresher.refresh_user_subs_list(current_user)
    morph :nothing
  end

  private

  def set_notification_subscription
    handle_unscoped do
      notification_id = element.dataset['notification-id']
      @notification_subscription = policy_scope(NotificationSubscription).find_by!(
        notification_id: notification_id, subscriber_id: current_user.id
      )
    end
  end
end
