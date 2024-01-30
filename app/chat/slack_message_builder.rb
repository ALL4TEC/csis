# frozen_string_literal: true

class SlackMessageBuilder
  class << self
    def build_msg(channel_id, notif)
      data = notif.data
      {
        channel: channel_id,
        blocks: [
          {
            type: 'header',
            text: {
              type: 'plain_text',
              text: data[:title]
            }
          },
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "<#{ENV.fetch('ROOT_URL', nil)}#{data[:path]}|*#{data[:message]}*>"
            }
          }
        ]
      }
    end
  end
end
