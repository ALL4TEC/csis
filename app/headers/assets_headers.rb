# frozen_string_literal: true

class AssetsHeaders < HeadersHandler
  TABS = {
    all: {
      subtitle: 'assets.scopes.all.subtitle',
      label: 'scopes.all',
      href: 'assets_path',
      badge: '_data.kept.count',
      icon: Icons::MAT[:dashboard]
    },
    trashed: {
      subtitle: 'assets.scopes.trashed.subtitle',
      label: 'scopes.trashed',
      href: 'trashed_assets_path',
      badge: '_data.trashed.count',
      icon: Icons::MAT[:delete]
    },
    overview: {
      label: 'scopes.overview',
      href: 'asset_path(_data)',
      icon: Icons::MAT[:dashboard]
    },
    targets: {
      label: 'models.targets',
      href: 'asset_targets_path(_data)',
      icon: Icons::MAT[:targets],
      badge: '_data.targets.count'
    }
  }.freeze

  ACTIONS = {
    new: {
      label: 'assets.actions.create',
      href: 'new_asset_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'assets.actions.edit',
      href: 'edit_asset_path(data)',
      icon: Icons::MAT[:edit]
    },
    create_target: {
      label: 'assets.actions.create_target',
      href: 'new_asset_target_path(data)',
      icon: Icons::MAT[:add]
    },
    destroy: {
      label: 'assets.actions.destroy',
      href: 'asset_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'assets.actions.destroy_confirm'
    },
    all_targets: {
      label: 'assets.actions.view_all_targets',
      href: 'targets_path',
      icon: Icons::MAT[:targets]
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
