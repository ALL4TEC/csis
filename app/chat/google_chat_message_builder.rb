# frozen_string_literal: true

class GoogleChatMessageBuilder
  class << self
    def build_msg(notif)
      data = notif.data
      {
        cards: [
          {
            sections: [
              {
                widgets: [
                  {
                    keyValue: {
                      topLabel: 'CSIS',
                      icon: 'TICKET',
                      contentMultiline: true,
                      content: 'Notification'
                    }
                  }
                ]
              },
              {
                widgets: [
                  {
                    keyValue: {
                      contentMultiline: true,
                      content: "<b> #{data[:title]} </b>"
                    }
                  }
                ]
              },
              {
                widgets: [
                  {
                    keyValue: {
                      content: data[:message],
                      contentMultiline: true,
                      onClick: {
                        openLink: {
                          url: "#{ENV.fetch('ROOT_URL', nil)}#{data[:path]}"
                        }
                      },
                      button: {
                        textButton: {
                          text: 'OPEN CSIS',
                          onClick: {
                            openLink: {
                              url: "#{ENV.fetch('ROOT_URL', nil)}#{data[:path]}"
                            }
                          }
                        }
                      }
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    end
  end
end
