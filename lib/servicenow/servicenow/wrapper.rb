# frozen_string_literal: true

class Servicenow::Wrapper
  attr_reader :servicenow_config

  def initialize(servicenow_config)
    raise Servicenow::Error, 'invalid ServicenowConfig' unless servicenow_config.persisted?

    @servicenow_config = servicenow_config
    if @servicenow_config.status.to_sym == :ok &&
       @servicenow_config.need_refresh_at < DateTime.current.advance(seconds: 10)
      update_tokens
    end
  end

  def create_issue(title, description: '')
    # TODO: add a "caller", otherwise the incident is inconsistent
    response = JSON.parse(
      Net::HTTP.post(
        URI("#{@servicenow_config.url}/api/now/table/incident"),
        {
          short_description: title,
          description: description,
          caller_id: current_user['user_sys_id']
        }.to_json,
        {
          Authorization: "Bearer #{@servicenow_config.login}",
          'Content-Type': 'application/json',
          Accept: 'application/json'
        }
      ).body
    )
    response['result']['sys_id']
  end

  def comment(incident_sys_id, text)
    put(
      URI("#{@servicenow_config.url}/api/now/table/incident/#{incident_sys_id}"),
      { comments: text }.to_json,
      {
        Authorization: "Bearer #{@servicenow_config.login}",
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    )
  end

  def close_issue(incident_sys_id, close_code)
    put(
      URI("#{@servicenow_config.url}/api/now/table/incident/#{incident_sys_id}"),
      {
        state: 7,
        close_notes: I18n.t('ticketing.comment.closed'),
        close_code: close_code
      }.to_json,
      {
        Authorization: "Bearer #{@servicenow_config.login}",
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    )
  end

  def issue_status(incident_sys_id)
    response = JSON.parse(
      Net::HTTP.get(
        URI("#{@servicenow_config.url}/api/now/table/incident/#{incident_sys_id}"),
        {
          Authorization: "Bearer #{@servicenow_config.login}",
          'Content-Type': 'application/json',
          Accept: 'application/json'
        }
      )
    )

    if response.key?('error')
      raise Servicenow::Error, "get issue failed: #{response['error']['detail']}"
    elsif response['result']['close_code'].empty?
      :open
    else
      :closed
    end
  end

  def current_user
    JSON.parse(
      Net::HTTP.get(
        URI("#{@servicenow_config.url}/api/now/ui/user/current_user"),
        {
          Authorization: "Bearer #{@servicenow_config.login}",
          'Content-Type': 'application/json',
          Accept: 'application/json'
        }
      )
    )['result']
  end

  def authorization_url
    "#{@servicenow_config.url}/oauth_auth.do?" \
      "response_type=code&redirect_uri=#{callback_url}" \
      "&client_id=#{@servicenow_config.api_key}" \
      "&state=#{@servicenow_config.id}" \
      '&scope=useraccount'
  end

  def trade_token(authorization_code)
    body = 'grant_type=authorization_code' \
           "&code=#{authorization_code}" \
           "&redirect_uri=#{callback_url}"
    response = do_oauth_request(body)

    if response.key?('error')
      @servicenow_config.update(status: :ko)
      raise Servicenow::Error, "trade token failed: #{response['error_description']}"
    else
      update_config(response)
    end
  end

  def update_tokens
    raise Servicenow::Error, 'invalid ServicenowConfig' if @servicenow_config.status.to_sym == :ko

    body = 'grant_type=refresh_token' \
           "&refresh_token=#{@servicenow_config.password}"
    response = do_oauth_request(body)

    if response.key?('error')
      @servicenow_config.update(status: :ko)
      raise Servicenow::Error, "update tokens failed: #{response['error_description']}"
    else
      update_config(response)
    end
  end

  private

  def callback_url
    "#{ENV.fetch('ROOT_URL')}/servicenow/oauth"
  end

  def oauth_request_uri
    URI("#{@servicenow_config.url}/oauth_token.do")
  end

  def do_oauth_request(body)
    JSON.parse(
      Net::HTTP.post(
        oauth_request_uri,
        body,
        token_headers_h
      ).body
    )
  end

  def update_config(response_h)
    @servicenow_config.update(
      login: response_h['access_token'],
      password: response_h['refresh_token'],
      need_refresh_at: DateTime.current.advance(seconds: response_h['expires_in']),
      status: :ok
    )
  end

  def token_headers_h
    auth = Base64
           .encode64("#{@servicenow_config.api_key}:#{@servicenow_config.secret_key}")
           .chomp
    {
      Authorization: "Basic #{auth}",
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  end

  # Because Net::HTTP has simple methods for GET & POST but not for other verbs
  # Inspired from Ruby 3.1.3 standard lib (/usr/share/ruby/net/http.rb:522)
  def put(url, data, header = nil)
    Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
      http.put(url, data, header)
    end
  end
end
