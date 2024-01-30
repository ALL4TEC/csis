# frozen_string_literal: true

class MicrosoftTeamsMessageBuilder
  class << self
    def build_msg(notif)
      data = notif.data
      {
        '@context': 'https://schema.org/extensions',
        '@type': 'MessageCard',
        themeColor: 'e36426',
        title: data[:title],
        text: data[:message],
        potentialAction: [
          {
            '@type': 'OpenUri',
            name: 'Open CSIS',
            targets: [
              { os: 'default', uri: "#{ENV.fetch('ROOT_URL', nil)}#{data[:path]}" }
            ]
          }
        ]
      }
    end
  end
end
