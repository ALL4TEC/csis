# frozen_string_literal: true

class Chat::SlackConfigMapper
  class << self
    def oauth_options_h(slack_app, code)
      {
        code: code,
        redirect_uri: "#{ENV.fetch('ROOT_URL')}/slack/oauth",
        client_id: slack_app.client_id,
        client_secret: slack_app.client_secret,
        app_id: slack_app.app_id
      }
    end

    def slack_config_h(slack_app, response, channel_h, current_user)
      entreprise = response['enterprise'].present? ? "#{response['enterprise']['name']}-" : ''
      team = response['team'].present? ? response['team']['name'] : ''
      {
        name: "#{entreprise}#{team}-#{SecureRandom.hex(10)}",
        workspace_name: "#{entreprise}#{team}",
        channel_name: channel_h[:channel_name],
        channel_id: channel_h[:channel_id],
        creator: current_user,
        external_application_id: slack_app.id,
        api_key: response['access_token'],
        bot_user_id: response['bot_user_id'],
        url: 'N/S' # Not Specified
      }
    end
  end
end
