# frozen_string_literal: true

class Configs::SlackConfigService
  class << self
    # Define options for connexion
    # **@params slack_application:** Slack application to add
    # **@params code:** Code returned by slack after STEP 1
    # @returns hash containing oauth options
    def build_oauth_options(slack_application, code)
      Chat::SlackConfigMapper.oauth_options_h(slack_application, code)
    end

    # **@params response:** The oauth response
    # **@params options:** Oauth options
    # **@returns :** The creation notice msg
    def handle_oauth_response(slack_app, response, options, current_user)
      if response['ok'] &&
         response['token_type'] == 'bot' &&
         response['app_id'] == options[:app_id]
        Rails.logger.debug('Slack oauth response ok')
        channel_h = find_channel(response)
        SlackConfig.create!(
          Chat::SlackConfigMapper.slack_config_h(slack_app, response, channel_h, current_user)
        )
        I18n.t('slack_configs.notices.creation_success')
      else
        Rails.logger.debug('Slack oauth response ko')
        I18n.t('slack_configs.notices.creation_failure')
      end
    end

    def fetch_channels(slack_config)
      channels = list_available_channels(slack_config.api_key)
      channels.present? ? channels.collect { |channel| [channel.name, channel.id] } : [['', '']]
    end

    private

    def list_available_channels(token)
      client = Slack::Web::Client.new(token: token)
      conversations_list_resp = client.conversations_list
      # Initialisation nécessaire si le channel est vide
      return [] unless conversations_list_resp['ok']

      conversations_list_resp.channels
    end

    # **oauth_response: ** Oauth Response
    # Use oauth_response['incoming_webhook'] data if present
    # Or first available channel
    def find_channel(oauth_response)
      if oauth_response['incoming_webhook'].present?
        channel_id = oauth_response['incoming_webhook']['channel_id']
        channel_name = oauth_response['incoming_webhook']['channel']
      else
        channels = list_available_channels(oauth_response['access_token'])
        channel_id = channels.first['id']
        channel_name = channels.first['name']
      end
      {
        channel_id: channel_id,
        channel_name: channel_name
      }
    end
  end
end
