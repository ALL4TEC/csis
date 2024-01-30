# frozen_string_literal: true

class SlackConfigsHeaders < ChatConfigsHeaders
  ACTIONS = {
    list: {
      label: 'slack_configs.section_title',
      href: 'slack_configs_path',
      icon: Icons::MAT[:list]
    },
    create: {
      label: 'slack_configs.actions.create',
      href: 'new_slack_config_path',
      icon: Icons::MAT[:add]
    },
    create_app: {
      label: 'slack_applications.actions.create',
      href: 'new_slack_application_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'slack_configs.actions.edit',
      href: 'edit_slack_config_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'slack_configs.actions.destroy',
      href: 'slack_config_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'slack_configs.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super(actions: ACTIONS)
  end
end
