# frozen_string_literal: true

class Chat::ZohoCliqConfigMapper
  class << self
    def chat_config_h(params, current_user)
      bot_name = params['bot_name']
      webhook_domain = params['webhook_domain']
      api_key = params['api_key']
      {
        name: bot_name,
        bot_name: bot_name,
        webhook_domain: webhook_domain,
        url: "#{webhook_domain}api/v2/bots/#{bot_name}/incoming?zapikey=#{api_key}",
        api_key: api_key,
        creator: current_user,
        user_ids: params['user_ids']
      }
    end
  end
end
