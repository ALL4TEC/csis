# frozen_string_literal: true

require 'styles'

module ActionsHelper
  STATES_MAP = {
    opened: { icon: 'help', color: 'critical' },
    to_fix: { icon: 'assignment', color: 'secondary' },
    assigned: { icon: 'assignment_ind', color: 'secondary' },
    fixed_vulnerability: { icon: 'assignment_turned_in', color: 'trivial' },
    accepted_risk_not_fixed: { icon: 'stars', color: 'trivial' },
    not_fixed: { icon: 'error', color: 'critical' },
    reviewed_fix: { icon: 'check_circle', color: 'trivial' },
    reopened: { icon: 'history', color: 'critical' }
  }.freeze

  META_STATES_MAP = {
    active: { icon: Icons::MAT[:actions], color: 'primary' },
    clotured: { icon: Icons::MAT[:actions], color: 'success' },
    archived: { icon: Icons::MAT[:archived], color: 'muted' }
  }.freeze

  OVERDUE_MAP = {
    no_due_date: { color: 'muted' },
    overdue: { color: 'critical' },
    to_do_today: { color: 'medium' },
    on_time: { color: 'trivial' }
  }.freeze

  PRIORITY_MAP = {
    no: { color: 'muted' },
    low: { color: 'trivial' },
    medium: { color: 'medium' },
    high: { color: 'critical' }
  }.freeze

  def action_state_icon(state)
    STATES_MAP[state.to_sym][:icon]
  end

  def action_state_color(state)
    STATES_MAP[state.to_sym][:color]
  end

  def action_meta_state_icon(meta_state)
    META_STATES_MAP[meta_state.to_sym][:icon]
  end

  def action_meta_state_color(meta_state)
    META_STATES_MAP[meta_state.to_sym][:color]
  end

  def action_due_date_status_icon
    Icons::MAT[:overdue]
  end

  def action_due_date_status_color(due_date_status)
    OVERDUE_MAP[due_date_status.to_sym][:color]
  end

  def action_priority_icon
    Icons::MAT[:priority]
  end

  def action_priority_color(priority)
    PRIORITY_MAP[priority.to_sym][:color]
  end
end
