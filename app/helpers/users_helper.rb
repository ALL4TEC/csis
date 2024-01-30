# frozen_string_literal: true

module UsersHelper
  ACTIVABLE_COLORS = {
    deactivate: 'danger',
    activate: 'success'
  }.freeze

  HEATMAP_CONNECTIONS_COLORS = %w[white light orange-l primary].freeze

  def current_user?(user)
    user == current_user
  end

  def activable_color(action)
    ACTIVABLE_COLORS[action]
  end

  def self.compute_heatmap(value)
    value = 3 if value > 3
    HEATMAP_CONNECTIONS_COLORS[value]
  end

  def policy_from_user_type(type, user, local_assigns)
    return nil if type.blank? # If user has no current group we stop

    local_assigns[:instanciated_policy] ||
      "#{type.capitalize}Policy".constantize.new(current_user, user)
  end
end
