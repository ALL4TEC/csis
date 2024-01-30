# frozen_string_literal: true

class ZohoCliqMessageBuilder
  class << self
    def build_msg(notif)
      data = notif.data
      {
        title: data[:title],
        text: data[:message],
        uri: "#{ENV.fetch('ROOT_URL', nil)}#{data[:path]}",
        instance: Domainatrix.parse(ENV.fetch('ROOT_URL', nil)).host.to_s
      }
    end
  end
end
