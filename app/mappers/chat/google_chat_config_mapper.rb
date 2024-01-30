# frozen_string_literal: true

class Chat::GoogleChatConfigMapper
  class << self
    def chat_config_h(params, current_user)
      {
        name: params['workspace_name'].to_s,
        creator: current_user,
        url: params['url'],
        api_key: params['url'],
        workspace_name: params['workspace_name'],
        user_ids: params['user_ids']
      }
    end
  end
end
