# frozen_string_literal: true

class AggregatesHeaders < HeadersHandler
  TABS = {
    details: {
      label: 'scopes.details',
      href: 'aggregate_path(_data)'
    },
    actions: {
      label: 'models.actions',
      href: 'aggregate_actions_path(_data)'
    }
  }.freeze

  ACTIONS = {
    edit: {
      label: 'aggregates.actions.edit',
      href: 'edit_aggregate_path(data)',
      icon: Icons::MAT[:edit]
    },
    create_action: {
      label: 'aggregates.actions.create_action',
      href: 'new_aggregate_action_path(data)',
      icon: Icons::MAT[:add]
    },
    destroy: {
      label: 'aggregates.actions.destroy',
      href: 'aggregate_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'aggregates.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
