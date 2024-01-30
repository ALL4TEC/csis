# frozen_string_literal: true

class Cyberwatch::Request
  class << self
    def do_list(account, api_path, api_params = {})
      do_request(account, api_path, api_params)
    end

    def do_singular(account, api_path, api_params = {})
      do_request(account, api_path, api_params)
    end

    # Sign a request
    def auth(account)
      call(account, 'v3', {}, sign_only: true)
    end

    # Ping CBW instance
    def ping(account)
      call(account, 'v3/ping', {})
    end

    protected

    # Create, sign and send request
    def call(account, api_path, api_params = {}, sign_only: false)
      uri = URI.parse("https://#{account.url}/#{api_path}")

      if api_params.present?
        query = URI.decode_www_form('')
        api_params.each do |key, value|
          query << [key.to_s, value.to_s]
        end
        uri.query = URI.encode_www_form(query)
      end

      request = Net::HTTP::Get.new(uri)
      signed_req = ApiAuth.sign!(request, account.api_key, account.secret_key, digest: 'sha256')
      return signed_req if sign_only

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = if account.verify_ssl_certificate
                           OpenSSL::SSL::VERIFY_PEER
                         else
                           OpenSSL::SSL::VERIFY_NONE
                         end
      http.request(signed_req)
    end

    # Handle call: exceptions + response
    def do_request(account, api_path, api_params = {}, sign_only: false)
      begin
        response = call(account, api_path, api_params, sign_only: sign_only)
      rescue Net::ReadTimeout
        raise Cyberwatch::Error, "#{uri} is NOT reachable (ReadTimeout)"
      rescue Net::OpenTimeout
        raise Cyberwatch::Error, "#{uri} is NOT reachable (OpenTimeout)"
      rescue StandardError => e
        raise Cyberwatch::Error, "Error during Api call: #{e}"
      end

      unless response.code.match?(/^2\d\d$/)
        Rails.logger.debug do
          "Error ! account: #{account}, path: #{api_path}, params: #{api_params}"
        end
        raise Cyberwatch::Error, "Error during Api call: #{response.code} #{response.message}"
      end

      JSON.parse(response.body)
    end
  end
end
