# frozen_string_literal: true

class SellsyConfigsHeaders < HeadersHandler
  ACTIONS = {
    list: {
      label: 'sellsy_configs.section_title',
      href: 'sellsy_configs_path',
      icon: Icons::MAT[:list]
    },
    create: {
      label: 'sellsy_configs.actions.create',
      href: 'new_sellsy_config_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'sellsy_configs.actions.edit',
      href: 'edit_sellsy_config_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'sellsy_configs.actions.destroy',
      href: 'sellsy_config_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'sellsy_configs.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super({}, ACTIONS)
  end
end
