# frozen_string_literal: true

class ChatConfigsHeaders < HeadersHandler
  TABS = {
    google_chat_configs: {
      label: 'google_chat_configs.section_title',
      href: 'google_chat_configs_path',
      logo: Icons::LOGOS[:google_chat]
    },
    microsoft_teams_configs: {
      label: 'microsoft_teams_configs.section_title',
      href: 'microsoft_teams_configs_path',
      logo: Icons::LOGOS[:microsoft_teams]
    },
    slack_configs: {
      label: 'slack_configs.section_title',
      href: 'slack_configs_path',
      logo: Icons::LOGOS[:slack]
    },
    zoho_cliq_configs: {
      label: 'zoho_cliq_configs.section_title',
      href: 'zoho_cliq_configs_path',
      logo: Icons::LOGOS[:zoho_cliq]
    }
  }.freeze

  def initialize(tabs: TABS, actions: {})
    super(tabs, actions)
  end
end
