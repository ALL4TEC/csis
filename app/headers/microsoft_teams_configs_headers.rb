# frozen_string_literal: true

class MicrosoftTeamsConfigsHeaders < ChatConfigsHeaders
  ACTIONS = {
    list: {
      label: 'microsoft_teams_configs.section_title',
      href: 'microsoft_teams_configs_path',
      icon: Icons::MAT[:list]
    },
    create: {
      label: 'microsoft_teams_configs.actions.create',
      href: 'new_microsoft_teams_config_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'microsoft_teams_configs.actions.edit',
      href: 'edit_microsoft_teams_config_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'microsoft_teams_configs.actions.destroy',
      href: 'microsoft_teams_config_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'microsoft_teams_configs.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super(actions: ACTIONS)
  end
end
