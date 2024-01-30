# frozen_string_literal: true

class GoogleChatConfigsHeaders < ChatConfigsHeaders
  ACTIONS = {
    list: {
      label: 'google_chat_configs.section_title',
      href: 'google_chats_path',
      icon: Icons::MAT[:list]
    },
    create: {
      label: 'google_chat_configs.actions.create',
      href: 'new_google_chat_config_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'google_chat_configs.actions.edit',
      href: 'edit_google_chat_config_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'google_chat_configs.actions.destroy',
      href: 'google_chat_config_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'google_chat_configs.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super(actions: ACTIONS)
  end
end
