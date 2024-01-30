# frozen_string_literal: true

require 'logger'

class QualysWa::ListResponse
  attr_reader :data

  def initialize(response, base_xpath, &block)
    if base_xpath.nil?
      @data = response.map(&block)
    elsif (@data = response.xpath(base_xpath).map(&block))
      # Lint/EmptyConditionalBody
    end
  end
end

class QualysWa::Request
  class << self
    # @param api: {path: string, method: string, params: {}}
    def do_list(account, klass, base_xpath, api)
      api[:params] ||= {}
      QualysWa::ListResponse.new(
        do_request(account, api[:path], api[:method], api[:params]),
        base_xpath
      ) do |node|
        klass.new(node)
      end
    end

    # @param api: {path: string, method: string, params: {}}
    def do_singular(account, klass, base_xpath, api)
      api[:params] ||= {}
      response = do_request(account, api[:path], api[:method], api[:params])
      klass.new(response.at_xpath(base_xpath))
    end

    protected

    def handle_params(api_params)
      name_filter = ''
      tags_filter = ''
      date_filter = ''
      api_params.each do |k, v|
        case k
        when :name
          # Filter by scan name
          name_filter = "<Criteria field='#{k}' operator='CONTAINS'>#{v}</Criteria>"
        when :'webApp.tags.id'
          # Filter by webApp tags ids comma separated list
          tags_filter = "<Criteria field='#{k}' operator='IN'>#{v}</Criteria>"
        when :launched_date
          # Filter by scan launched date
          v += 'T00:00:00Z'
          date_filter = "<Criteria field='launchedDate' operator='GREATER'>#{v}</Criteria>"
        else
          Rails.logger.info "QualysWa::ListResponse: Unfiltered params to handle: #{k}"
        end
      end
      '<ServiceRequest><preferences><limitResults>1000</limitResults></preferences><filters>' \
        "<Criteria field='status' operator='IN'>FINISHED, ERROR, CANCELED</Criteria>" \
        "<Criteria field='type' operator='NOT EQUALS'>DISCOVERY</Criteria>" \
        "#{name_filter}" \
        "#{tags_filter}" \
        "#{date_filter}" \
        '</filters></ServiceRequest>'
    end

    def handle_output(response, output_format)
      if output_format.nil? || output_format == 'xml'
        Nokogiri::XML(response.body)
      elsif output_format == 'json'
        JSON.parse(response.body)
      else
        raise QualysWa::Error,
          "Unknown response format requested, was #{output_format}"
      end
    end

    def handle_error(response, account, api_path, api_method, api_params)
      return unless (error, message = error_parsing(response))

      Rails.logger.debug do
        "Error ! account: #{account}, path: #{api_path},
        method: #{api_method}, params: #{api_params}"
      end
      raise Qualys::Error, "Error during Api call: #{error} #{message}"
    end

    def create_request(uri, api_method)
      if api_method == 'POST'
        Net::HTTP::Post.new(uri)
      else
        Net::HTTP::Get.new(uri)
      end
    end

    def error_parsing(response)
      return response.code, response.message unless response.code.match?(/^2\d\d$/)

      body = Nokogiri::HTML.fragment(response.body)
      code = body.search('responsecode').text
      if code == 'SUCCESS' || code.empty?
        false
      else
        [code, body.search('errormessage').text]
      end
    end

    def do_request(account, api_path, api_method, api_params = {})
      begin
        uri = URI.parse("https://#{account.url}/qps/rest/3.0/#{api_path}")
        request = create_request(uri, api_method)
        # On envoie le body uniquement si search
        # + options si presentes
        add_body_condition = api_path.include?('search/was/wasscan') && api_params.present?
        request.body = handle_params(api_params) if add_body_condition
        request['Content-Type'] = 'text/xml'
        request['Connection'] = 'keep-alive'
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
        raise QualysWa::Error, "#{uri.hostname}:#{uri.port} is NOT reachable(ReadTimeout)"
      rescue Net::OpenTimeout
        raise QualysWa::Error, "#{uri.hostname}:#{uri.port} is NOT reachable(OpenTimeout)"
      rescue StandardError => e
        raise QualysWa::Error, "Error during Api call: #{e}"
      end
      handle_error(response, account, api_path, api_method, api_params)
      handle_output(response, api_params[:output_format])
    end
  end
end
