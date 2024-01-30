# frozen_string_literal: true

class Sellsy::ListResponse
  attr_reader :method, :per_page, :page, :total, :data

  def initialize(api_method, response)
    @method = api_method
    @per_page = response['infos']['nbperpage'].to_i
    @page = response['infos']['pagenum'].to_i
    @total = response['infos']['nbtotal'].to_i
    @data = response['result'].map { |_k, v| v }
  end
end

class Sellsy::Request
  class << self
    def do_list(klass, api_method, api_params = {}, account = SellsyConfig.first)
      response = Sellsy::ListResponse.new(
        api_method,
        self.do(api_method, api_params, account)['response']
      )
      response.data = response.data.map { |h| klass.new(h) }
      response
    end

    def do_singular(_klass, api_method, api_params = {}, account = SellsyConfig.first)
      self.do(api_method, api_params, account)['response']
    end

    protected

    def do(api_method, api_params = {}, account = SellsyConfig.first)
      begin
        # Set the API URL
        url = URI('https://apifeed.sellsy.com/0/')
        # Define the timestamp & a random nonce
        timestamp = Time.now.to_i
        nonce = SecureRandom.hex(6)
        # Setup the URL host and port, and force to use SSL
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        # Store the POST request in a new var
        request = Net::HTTP::Post.new(url)
        # HTTP request headers
        request['cache-control'] = 'no-cache'
        request['accept'] = '*/*'
        request['content-type'] = 'application/x-www-form-urlencoded'
        # HTTP request body
        request.set_form_data(
          'do_in' => {
            'method' => api_method,
            'params' => api_params
          }.to_json,
          'io_mode' => 'json',
          'request' => 1,
          # Consumer Token
          'oauth_consumer_key' => account.consumer_token,
          # User token
          'oauth_token' => account.user_token,
          'oauth_signature_method' => 'PLAINTEXT',
          'oauth_timestamp' => timestamp,
          'oauth_nonce' => nonce,
          'oauth_version' => 1.0,
          # Consumer secret & User secret
          'oauth_signature' => "#{account.consumer_secret}&#{account.user_secret}"
        )
        response = http.request(request)
        payload = JSON.parse(response.read_body)
      rescue Net::ReadTimeout
        raise Sellsy::Error, "#{url.host}:#{url.port} is NOT reachable (ReadTimeout)"
      rescue Net::OpenTimeout
        raise Sellsy::Error, "#{url.host}:#{url.port} is NOT reachable (OpenTimeout)"
      rescue StandardError => e
        raise Sellsy::Error, "Error during Api call: #{e}"
      end
      raise Sellsy::Error, payload['error'] if payload['status'] != 'success'

      payload
    end
  end
end
