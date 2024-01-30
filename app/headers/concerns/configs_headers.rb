# frozen_string_literal: true

class ConfigsHeaders < HeadersHandler
  def initialize(h_tabs = {}, h_actions = {})
    clazzs = self.class.name.to_s.underscore.sub!('_headers', '')
    clazz = clazzs.singularize
    tabs = {}.freeze
    actions = {
      list: {
        label: "#{clazzs}.section_title",
        href: "#{clazzs}_path",
        icon: Icons::MAT[:list]
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
        icon: Icons::MAT[:deactivate]
      }
    }.freeze
    super(tabs.merge(h_tabs), actions.merge(h_actions))
  end
end
