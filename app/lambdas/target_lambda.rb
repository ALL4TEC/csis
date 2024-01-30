# frozen_string_literal: true

class TargetLambda
  class << self
    def only_containing_ip(ip_list)
      ->(target) { target.ip.in?(ip_list) }
    end

    def only_containing_url(url_list)
      ->(target) { target.url.in?(url_list) }
    end
  end
end
