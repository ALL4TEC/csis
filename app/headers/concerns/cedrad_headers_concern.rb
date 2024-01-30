# frozen_string_literal: true

# CreateEditDestroyRestoreActivateDeactivate HeadersConcern
class CedradHeadersConcern < HeadersHandler
  def initialize
    clazzs = self.class.name.to_s.underscore.sub!('_headers', '')
    clazz = clazzs.singularize
    tabs = {}.freeze
    actions = {
      create: {
        label: "#{clazzs}.actions.create",
        href: "new_#{clazz}_path",
        icon: if clazz.capitalize.in?(%w[Team
                                         Client])
                Icons::MAT[:group_add]
              else
                Icons::MAT[:person_add]
              end
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
      }
    }
    if clazz.capitalize.in?(%w[Staff Contact])
      [
        [:resend_confirmation, { icon: Icons::MAT[:send_confirmation] }],
        [:activate],
        [:deactivate],
        [:send_unlock, { method: :post, icon: Icons::MAT[:unlock] }],
        [:send_reset_password, { method: :post }],
        [:force_unlock, { icon: Icons::MAT[:unlock] }],
        [:force_confirm, { icon: Icons::MAT[:verified] }],
        [:force_direct_otp],
        [:force_deactivate_otp, { icon: Icons::MAT[:no_otp] }],
        [:force_unlock_otp, { icon: Icons::MAT[:unlock] }]
      ].each do |name, data|
        actions[name] = build_h(clazzs, clazz, name, data || {})
      end
    end
    super(tabs, actions)
  end
end
