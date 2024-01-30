# frozen_string_literal: true

class PrivateIpValidator
  LOCAL_RGXP = /(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/

  # 172.16.0.0 – 172.31.255.255
  def self.local_cluster_request_origin?(remote_ip)
    LOCAL_RGXP.match?(remote_ip) ||
      ENV.fetch('SCB_WEBHOOK_WHITELIST') { |_| '' }.split(',').map(&:strip).include?(remote_ip)
  end
end
