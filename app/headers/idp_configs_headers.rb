# frozen_string_literal: true

class IdpConfigsHeaders < HeadersHandler
  def initialize
    clazzs = 'idp_configs'
    clazz = 'idp_config'
    tabs = {}.freeze
    actions = {
      back: {
        label: 'section_header.actions.back',
        href: 'data',
        icon: Icons::MAT[:back]
      },
      create: {
        label: "#{clazzs}.actions.create",
        href: "new_#{clazz}_path",
        icon: Icons::MAT[:add]
      },
      edit: {
        label: "#{clazzs}.actions.edit",
        href: "edit_#{clazz}_path(data)",
        icon: Icons::MAT[:edit]
      },
      destroy: {
        label: "#{clazzs}.actions.destroy",
        href: "#{clazz}_path(data)",
        method: :delete,
        icon: Icons::MAT[:delete],
        confirm: "#{clazzs}.actions.destroy_confirm"
      },
      restore: {
        label: "#{clazzs}.actions.restore",
        href: "restore_#{clazz}_path(data)",
        method: :put,
        icon: Icons::MAT[:restore],
        confirm: "#{clazzs}.actions.restore_confirm"
      },
      activate: {
        label: "#{clazzs}.actions.activate",
        href: "activate_#{clazz}_path(data)",
        method: :put,
        icon: Icons::MAT[:activate]
      },
      deactivate: {
        label: "#{clazzs}.actions.deactivate",
        href: "deactivate_#{clazz}_path(data)",
        method: :put,
        icon: Icons::MAT[:idp_configs]
      }
    }
    super(tabs, actions)
  end
end
