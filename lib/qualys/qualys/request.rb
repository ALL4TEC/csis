# frozen_string_literal: true

class Qualys::Request
  class << self
    def do_list(account, klass, base_xpath, api_path, api_params = {})
      Qualys::ListResponse.new(do_request(account, api_path, api_params),
        base_xpath) do |node|
        klass.new(node)
      end
    end

    def do_singular(account, klass, base_xpath, api_path, api_params = {})
      response = do_request(account, api_path, api_params)
      if base_xpath.nil?
        klass.new(response)
      else
        response.at_xpath(base_xpath).map { |node| klass.new(node) }
      end
    end

    protected

    def handle_output(response, output_format)
      if output_format.nil? || output_format == 'xml'
        Nokogiri::XML(response.body)
      elsif output_format == 'json'
        JSON.parse(response.body)
      else
        raise Qualys::Error,
          "Unknown response format requested, was #{output_format}"
      end
    end

    def handle_error(response, account, api_path, api_params)
      return if response.code.match?(/^2\d\d$/)

      Rails.logger.debug do
        "Error ! account: #{account}, path: #{api_path}, params: #{api_params}"
      end
      raise Qualys::Error, "Error during Api call: #{response.code} #{response.message}"
    end

    def do_request(account, api_path, api_params = {})
      begin
        query = URI.decode_www_form('')
        api_params.each do |key, value|
          query << [key.to_s, value.to_s]
        end

        uri = URI.parse("https://#{account.url}/api/2.0/fo/#{api_path}")
        uri.query = URI.encode_www_form(query)
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(
          account.login,
          account.password
        )
        request['X-Requested-With'] = 'Qualys Ruby Client'
        req_options = {
          use_ssl: uri.scheme == 'https'
        }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
      rescue Net::ReadTimeout
        raise Qualys::Error, "#{uri} is NOT reachable (ReadTimeout)"
      rescue Net::OpenTimeout
        raise Qualys::Error, "#{uri} is NOT reachable (OpenTimeout)"
      rescue StandardError => e
        raise Qualys::Error, "Error during Api call: #{e}"
      end
      handle_error(response, account, api_path, api_params)
      handle_output(response, api_params[:output_format])
    end
  end
end
