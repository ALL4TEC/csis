# frozen_string_literal: true

class NotificationSubscription < ApplicationRecord
  include Discard::Model
  include EnumSelect

  self.table_name = 'notifications_subscriptions'

  belongs_to :notification,
    class_name: 'Notification',
    inverse_of: :notifications_subscriptions,
    primary_key: :id

  belongs_to :subscriber,
    class_name: 'User',
    inverse_of: :notifications_subscriptions,
    primary_key: :id

  validates :state, presence: true

  enum_with_select :state, { unread: 0, sent: 1, read: 2 }

  scope :last_created_first, -> { joins(:notification).order('notification.created_at desc') }

  def state_class
    read? ? 'read' : 'not-read'
  end
end
