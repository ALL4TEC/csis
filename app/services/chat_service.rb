# frozen_string_literal: true

class ChatService
  class << self
    # **@params account_user:** Account_user to fetch channels from
    # **@returns :** conversations_list.channels as [name, id] array
    # or [account_user.channel_id, 'default'] otherwise
    def channels(account_user)
      send(:"#{account_user.provider}_channels")
    end

    def slack_channels(account_user)
      response = Slack::Web::Client.new(token: account_user.account.api_key).conversations_list
      if response['ok']
        response.channels.collect { |c| [c.name, c.id] }
      else
        [account_user.channel_id.to_s, 'default']
      end
    end
  end
end
