# frozen_string_literal: true

class Chat::MicrosoftTeamsConfigMapper
  class << self
    def chat_config_h(params, current_user)
      {
        name: params['channel_name'].to_s,
        creator: current_user,
        url: params['url'],
        api_key: params['url'],
        channel_name: params['channel_name'],
        user_ids: params['user_ids']
      }
    end
  end
end
