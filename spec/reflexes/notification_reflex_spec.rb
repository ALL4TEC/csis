# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationReflex, type: :reflex do
  fixtures :all
  # https://github.com/podia/stimulus_reflex_testing

  describe '#toggle_state' do
    context 'if no notification subscription' do
      it 'it does not toggle state and displays alert' do
        # GIVEN
        user = User.first
        notification = NotificationSubscription.where.not(subscriber_id: user.id).first
                                               .notification
        reflex = build_reflex(
          url: dashboard_url(only_path: true),
          connection: { current_user: user }
        )
        reflex.element.dataset['notification-id'] = notification.id
        # WHEN/THEN
        catch(:abort) do
          reflex.send(:set_notification_subscription)
          broadcast(prepend: { selector: ApplicationReflex::CSIS_TOAST_SEL }, broadcast: nil)
        end
      end
    end

    context 'if notification subscription' do
      it 'toggles state' do
        # GIVEN
        notification_subscription = NotificationSubscription.first
        user = notification_subscription.subscriber
        previous_state = notification_subscription.state
        notification = notification_subscription.notification
        reflex = build_reflex(
          url: dashboard_url(only_path: true),
          connection: { current_user: user }
        )
        reflex.element.dataset['notification-id'] = notification.id
        # WHEN
        reflex.send(:set_notification_subscription)
        subject = reflex.run(:toggle_state)
        # THEN
        notification_subscription.reload
        expect(notification_subscription.state).not_to eq(previous_state)
        broadcast(
          morph: { selector: ActionView::RecordIdentifier.dom_id(notification_subscription) },
          broadcast: nil
        )
        expect(subject).to morph :nothing
      end
    end
  end

  describe '#clear' do
    context 'if no notification subscription' do
      it 'does nothing and displays alert' do
        # GIVEN
        user = User.first
        notification = NotificationSubscription.where.not(subscriber_id: user.id).first
                                               .notification
        reflex = build_reflex(
          url: dashboard_url(only_path: true),
          connection: { current_user: user }
        )
        reflex.element.dataset['notification-id'] = notification.id
        # WHEN/THEN
        catch(:abort) do
          reflex.send(:set_notification_subscription)
          broadcast(prepend: { selector: ApplicationReflex::CSIS_TOAST_SEL }, broadcast: nil)
        end
      end
    end

    context 'if notification subscription' do
      it 'discards notification_subscription' do
        # GIVEN
        notification_subscription = NotificationSubscription.first
        user = notification_subscription.subscriber
        expect(notification_subscription.discarded?).not_to be(true)
        notification = notification_subscription.notification
        reflex = build_reflex(
          url: dashboard_url(only_path: true),
          connection: { current_user: user }
        )
        reflex.element.dataset['notification-id'] = notification.id
        # WHEN
        reflex.send(:set_notification_subscription)
        subject = reflex.run(:clear)
        # THEN
        notification_subscription.reload
        expect(notification_subscription.discarded?).to be(true)
        broadcast(
          text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
          broadcast: nil
        )
        broadcast(remove: ActionView::RecordIdentifier.dom_id(notification_subscription))
        expect(subject).to morph :nothing
      end
    end
  end

  describe '#clear_all' do
    it 'discards all user.notification_subscriptions' do
      # GIVEN
      notification_subscription = NotificationSubscription.first
      user = notification_subscription.subscriber
      expect(user.notifications_subscriptions.all?(&:discarded?)).not_to be(true)
      reflex = build_reflex(
        url: dashboard_url(only_path: true),
        connection: { current_user: user }
      )
      # WHEN
      subject = reflex.run(:clear_all)
      # THEN
      user.reload
      expect(user.notifications_subscriptions.all?(&:discarded?)).to be(true)
      broadcast(
        text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
        broadcast: nil
      )
      broadcast(
        inner_html: { selector: NotificationRefresher::NOTIF_LIST_SEL },
        broadcast: nil
      )
      expect(subject).to morph :nothing
    end
  end

  describe '#restore_all' do
    it 'undiscards all user.notification_subscriptions' do
      # GIVEN
      # Discarding
      notification_subscription = NotificationSubscription.first
      user = notification_subscription.subscriber
      expect(user.notifications_subscriptions.all?(&:discarded?)).not_to be(true)
      reflex = build_reflex(
        url: dashboard_url(only_path: true),
        connection: { current_user: user }
      )
      subject = reflex.run(:clear_all)
      user.reload
      expect(user.notifications_subscriptions.all?(&:discarded?)).to be(true)
      broadcast(
        text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
        broadcast: nil
      )
      broadcast(
        inner_html: { selector: NotificationRefresher::NOTIF_LIST_SEL },
        broadcast: nil
      )
      expect(subject).to morph :nothing
      # WHEN
      reflex = build_reflex(
        url: dashboard_url(only_path: true),
        connection: { current_user: user }
      )
      subject2 = reflex.run(:restore_all)
      # THEN
      # Undiscarding
      user.reload
      expect(user.notifications_subscriptions.all?(&:discarded?)).to be(false)
      broadcast(
        text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
        broadcast: nil
      )
      broadcast(
        inner_html: { selector: NotificationRefresher::NOTIF_LIST_SEL },
        broadcast: nil
      )
      expect(subject2).to morph :nothing
    end
  end

  describe '#read_all' do
    it 'mark all user.notification_subscriptions as :read' do
      # GIVEN
      notification_subscription = NotificationSubscription.first
      user = notification_subscription.subscriber
      expect(user.notifications_subscriptions.all?(&:read?)).not_to be(true)
      reflex = build_reflex(
        url: dashboard_url(only_path: true),
        connection: { current_user: user }
      )
      # WHEN
      subject = reflex.run(:read_all)
      # THEN
      user.reload
      expect(user.notifications_subscriptions.all?(&:read?)).to be(true)
      broadcast(
        text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
        broadcast: nil
      )
      broadcast(
        inner_html: { selector: NotificationRefresher::NOTIF_LIST_SEL },
        broadcast: nil
      )
      expect(subject).to morph :nothing
    end
  end

  describe '#unread_all' do
    it 'mark all user.notification_subscriptions as :unread' do
      # GIVEN
      # Marking as read
      notification_subscription = NotificationSubscription.first
      user = notification_subscription.subscriber
      expect(user.notifications_subscriptions.all?(&:read?)).not_to be(true)
      reflex = build_reflex(
        url: dashboard_url(only_path: true),
        connection: { current_user: user }
      )
      subject = reflex.run(:read_all)
      user.reload
      expect(user.notifications_subscriptions.all?(&:read?)).to be(true)
      broadcast(
        text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
        broadcast: nil
      )
      broadcast(
        inner_html: { selector: NotificationRefresher::NOTIF_LIST_SEL },
        broadcast: nil
      )
      expect(subject).to morph :nothing
      # WHEN
      # Mark as unread
      reflex = build_reflex(
        url: dashboard_url(only_path: true),
        connection: { current_user: user }
      )
      subject2 = reflex.run(:unread_all)
      # THEN
      user.reload
      expect(user.notifications_subscriptions.all?(&:unread?)).to be(true)
      broadcast(
        text_content: { selector: NotificationRefresher::NOTIF_COUNTER_SEL },
        broadcast: nil
      )
      broadcast(
        inner_html: { selector: NotificationRefresher::NOTIF_LIST_SEL },
        broadcast: nil
      )
      expect(subject2).to morph :nothing
    end
  end
end
