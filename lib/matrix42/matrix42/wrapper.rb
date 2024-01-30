# frozen_string_literal: true

class Matrix42::Wrapper
  attr_reader :matrix42_config

  def initialize(matrix42_config)
    @matrix42_config = matrix42_config

    unless server_reachable?
      @matrix42_config.update(status: :url_ko)
      @matrix42_config = nil
      raise Matrix42::Error, 'invalid Matrix42Config url'
    end

    # to avoid a comparison between a DateTime and nil at the next 'if'
    update_access_token if @matrix42_config.need_refresh_at.nil?

    if @matrix42_config.status.to_sym != :url_ko &&
       @matrix42_config.need_refresh_at < DateTime.current.advance(seconds: 10)
      update_access_token
    end

    @matrix42_config.update(status: :ok)
  end

  def server_reachable?
    # very unofficial way of testing if the URL really points to a Matrix42 API
    response1 = Net::HTTP.get_response(
      URI("#{@matrix42_config.api_url}/api/ticket/search")
    )

    response2 = JSON.parse(
      Net::HTTP.get(
        URI("#{@matrix42_config.api_url}/api/data")
      )
    )

    response1.instance_of?(Net::HTTPUnauthorized) &&
      response2 == [{
        'Key' => 'Message',
        'Value' => 'The requested resource does not support http method \'GET\'.'
      }]
  rescue JSON::ParserError # if request got HTML instead of expected JSON
    false
  end

  def update_access_token
    response = JSON.parse(
      Net::HTTP.post(
        URI("#{@matrix42_config.api_url}/api/ApiToken/GenerateAccessTokenFromApiToken/"),
        nil,
        {
          Authorization: "Bearer #{@matrix42_config.api_key}",
          'Content-Type': 'application/json'
        }
      ).body
    )

    if response.nil?
      @matrix42_config.update(status: :auth_ko)
      raise Matrix42::Error, 'invalid Matrix42Config API key'
    end

    @matrix42_config.update(
      secret_key: response['RawToken'],
      need_refresh_at: response['LifeTime']
    )
  end

  def create_ticket(subject, type, description)
    type = { incident: 0, ticket: 5, service_request: 6 }[type]

    response = JSON.parse(
      Net::HTTP.post(
        URI("#{@matrix42_config.api_url}/api/ticket/create?activitytype=#{type}"),
        {
          Subject: subject,
          Description: description,
          User: current_user_id
        }.to_json,
        headers_h
      ).body
    )

    if response['ExceptionName'] == 'unauthorizedaccessexception' ||
       response['ExceptionName'] == 'spssecurityexception'
      raise Matrix42::Error, response['Message']
    end

    ticket_id_to_ticket_number(response)
  end

  def comment(ticket_number, text)
    response = Net::HTTP.post(
      URI("#{@matrix42_config.api_url}/api/journal/add"),
      {
        ObjectId: ticket_number_to_ticket_id(ticket_number),
        Comments: "<p>#{text}</p>"
      }.to_json,
      headers_h
    )

    raise Matrix42::Error, 'comment failed' unless response.instance_of?(Net::HTTPOK)
  end

  def close_ticket(ticket_number, reason, solution_description)
    reason = { solved: 408, known_error: 413 }[reason]

    response = Net::HTTP.post(
      URI("#{@matrix42_config.api_url}/api/ticket/close"),
      {
        ObjectIds: [ticket_number_to_ticket_id(ticket_number)],
        Reason: reason,
        Comments: solution_description,
        ErrorType: 0 # means 'unknown', see https://help.matrix42.com/030_DWP/030_INT/Business_Processes_and_API_Integrations/Public_API_reference_documentation/Close_an_Incident_or_a_Service_request
      }.to_json,
      headers_h
    )

    return if response.instance_of?(Net::HTTPNoContent)

    raise Matrix42::Error, 'close ticket failed (should be classified incident or service \
                              request before closing)'
  end

  def ticket_status(ticket_number)
    ticket = get_ticket(ticket_number)

    if ticket['State'] == 204
      :closed
    else
      :open
    end
  end

  def ticket_closable?(ticket_number)
    ticket = get_ticket(ticket_number)

    # ticket can be closed only when it has been transformed to incident or service request
    ticket['TypeName'] != 'SPSActivityTypeTicket'
  end

  private

  def headers_h
    {
      Authorization: "Bearer #{@matrix42_config.secret_key}",
      'Content-Type': 'application/json'
    }
  end

  def current_user_id
    JSON.parse(
      Net::HTTP.get(
        URI("#{@matrix42_config.api_url}/api/userinfo"),
        headers_h
      )
    )['Id']
  end

  def get_ticket(ticket_number)
    response = JSON.parse(
      Net::HTTP.get_response(
        URI("#{@matrix42_config.api_url}/api/ticket/search?TicketNumber=#{ticket_number}"),
        headers_h
      ).body
    )

    if response.key?('ExceptionName')
      raise Matrix42::Error, "get ticket failed: #{response['Message']} - " \
                             "#{response['ExceptionName']}"
    end

    response['Tickets'][0]
  end

  def ticket_id_to_ticket_number(id)
    # get ticket ciName
    ci_name = JSON.parse(
      Net::HTTP.get_response(
        URI("#{@matrix42_config.api_url}/api/ticket/GetTicketEntityType/#{id}"),
        headers_h
      ).body
    )
    # get ticket
    ticket = JSON.parse(
      Net::HTTP.get_response(
        URI("#{@matrix42_config.api_url}/api/data/objects/#{ci_name}/#{id}?full=true"),
        headers_h
      ).body
    )
    ticket['SPSActivityClassBase']['TicketNumber']
  end

  def ticket_number_to_ticket_id(ticket_number)
    get_ticket(ticket_number)['Id']
  end
end
