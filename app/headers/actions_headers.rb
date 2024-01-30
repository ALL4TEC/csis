# frozen_string_literal: true

class ActionsHeaders < HeadersHandler
  TABS = {
    details: {
      label: 'scopes.details',
      href: 'action_path(_data)'
    },
    active: {
      label: 'actions.scopes.active.name',
      href: 'actions_path',
      badge: '_data.kept.active.count',
      icon: Icons::MAT[:actions]
    },
    clotured: {
      label: 'actions.scopes.clotured.name',
      href: 'clotured_actions_path',
      badge: '_data.kept.clotured.count',
      icon: Icons::MAT[:done]
    },
    archived: {
      label: 'actions.scopes.archived.name',
      href: 'archived_actions_path',
      badge: '_data.kept.archived.count',
      icon: Icons::MAT[:archived]
    },
    trashed: {
      label: 'actions.scopes.trashed.name',
      href: 'trashed_actions_path',
      badge: '_data.trashed.count',
      icon: Icons::MAT[:delete]
    },
    dependencies: {
      label: 'models.dependencies',
      href: 'action_dependencies_path(_data)',
      badge: '_data.action_p.count'
    }
  }.freeze

  ACTIONS = {
    edit: {
      label: 'actions.actions.edit',
      href: 'edit_action_path(data)',
      icon: Icons::MAT[:edit]
    },
    create_dependency: {
      label: 'actions.actions.create_dependency',
      href: 'new_action_dependency_path(data)',
      icon: Icons::MAT[:add]
    },
    destroy: {
      label: 'actions.actions.destroy',
      href: 'action_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'actions.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
