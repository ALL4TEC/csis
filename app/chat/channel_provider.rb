# frozen_string_literal: true

class ChannelProvider
  DEFAULT_HEADERS = { 'Content-Type': 'application/json; charset=UTF-8' }.freeze

  class << self
    # **@params res:** Token or uri
    # **@params provider: ** chat provider
    # **@params channel_id: **
    # **@params notif: **
    def send_msg(res, provider, channel_id, notif)
      send(:"send_#{provider}_msg", res, channel_id, notif)
    end

    private

    def send_slack_msg(token, channel_id, notif)
      msg_payload = SlackMessageBuilder.build_msg(channel_id, notif)
      Rails.logger.info("Sending slack msg #{msg_payload} to #{channel_id}")
      client = Slack::Web::Client.new(token: token)
      client.chat_postMessage(msg_payload)
    rescue StandardError => e
      Rails.logger.error("Could not send slack msg due to: #{e.message}")
    end

    def send_google_chat_msg(token, _channel_id, notif)
      send_json_msg(token, GoogleChatMessageBuilder.build_msg(notif))
    end

    def send_microsoft_teams_msg(token, _channel_id, notif)
      send_json_msg(token, MicrosoftTeamsMessageBuilder.build_msg(notif))
    end

    def send_zoho_cliq_msg(token, _channel_id, notif)
      send_json_msg(token, ZohoCliqMessageBuilder.build_msg(notif))
    end

    def send_json_msg(uri, payload, headers = DEFAULT_HEADERS)
      Faraday.post(uri, payload.to_json, headers)
      Rails.logger.info("Sending msg #{payload} to #{uri}")
    rescue StandardError => e
      Rails.logger.error("Could not send msg due to: #{e.message}")
    end
  end
end
