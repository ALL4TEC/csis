# frozen_string_literal: true

class NotificationSubscriptionPolicy < ApplicationPolicy
  def permitted_attributes
    [:state]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.notifications_subscriptions
    end
  end
end
