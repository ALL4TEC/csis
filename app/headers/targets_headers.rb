# frozen_string_literal: true

class TargetsHeaders < HeadersHandler
  TABS = {
    all: {
      subtitle: 'targets.scopes.all.subtitle',
      label: 'scopes.all',
      href: 'asset_targets_path',
      badge: '_data.kept.count',
      icon: Icons::MAT[:dashboard]
    },
    trashed: {
      subtitle: 'targets.scopes.trashed.subtitle',
      label: 'scopes.trashed',
      href: 'trashed_targets_path',
      badge: '_data.trashed.count',
      icon: Icons::MAT[:delete]
    }
  }.freeze

  ACTIONS = {
    new: {
      label: 'targets.actions.create',
      href: 'new_asset_target_path(data)',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'targets.actions.edit',
      href: 'edit_target_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'targets.actions.destroy',
      href: 'target_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'targets.actions.destroy_confirm'
    },
    all_assets: {
      label: 'targets.actions.view_all_assets',
      href: 'assets_path',
      icon: Icons::MAT[:assets]
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
