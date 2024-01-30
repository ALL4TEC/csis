# frozen_string_literal: true

class QualysClientsHeaders < ConfigsHeaders
  def initialize
    clazzs = self.class.name.to_s.underscore.sub!('_headers', '')
    clazz = clazzs.singularize
    tabs = {}.freeze
    actions = {
      index: {
        label: "#{clazzs}.section_title",
        href: "qualys_config_#{clazzs}_path(data)",
        icon: Icons::MAT[:list]
      },
      create: {
        label: "#{clazzs}.actions.create",
        href: "new_qualys_config_#{clazz}_path(data)",
        icon: Icons::MAT[:add]
      }
    }.freeze
    super(tabs, actions)
  end
end
