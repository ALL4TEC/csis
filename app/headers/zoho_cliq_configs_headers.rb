# frozen_string_literal: true

class ZohoCliqConfigsHeaders < ChatConfigsHeaders
  ACTIONS = {
    list: {
      label: 'zoho_cliq_configs.section_title',
      href: 'zoho_cliq_configs_path',
      icon: Icons::MAT[:list]
    },
    create: {
      label: 'zoho_cliq_configs.actions.create',
      href: 'new_zoho_cliq_config_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'zoho_cliq_configs.actions.edit',
      href: 'edit_zoho_cliq_config_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'zoho_cliq_configs.actions.destroy',
      href: 'zoho_cliq_config_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'zoho_cliq_configs.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super(actions: ACTIONS)
  end
end
