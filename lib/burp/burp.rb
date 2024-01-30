# frozen_string_literal: true

# To parse this XML, add 'dry-struct' and 'dry-types' gems, then do:
#
#   burp = Burp.from_xml! "<...>"
#   puts burp.issues
#
# If from_xml! succeeds, the value returned matches the schema.

require 'common/types'
require 'common/xml'

module Types
  include Common::Types
end

class Burp < Dry::Struct
  extend Common::Xml

  class Issue < Dry::Struct
    extend Common::Xml

    attribute :name,                          Types::String.optional
    attribute :type,                          Types::String.optional
    attribute :severity,                      Types::String.optional
    attribute :vulnerability_classifications, Types::String.optional
    attribute :references,                    Types::String.optional
    attribute :issue_background,              Types::String.optional
    attribute :remediation_background,        Types::String.optional
    attribute :confidence,                    Types::String.optional
    attribute :host,                          Types::String.optional
    attribute :ip,                            Types::String.optional
    attribute :path,                          Types::String.optional
    attribute :location,                      Types::String.optional
    attribute :request_response,              Types::String.optional
    attribute :remediation_detail,            Types::String.optional
    attribute :issue_detail,                  Types::String.optional
    attribute :serial_number,                 Types::String.optional

    def self.from_dynamic!(data)
      new(
        name: get_text(data, './/name'),
        type: get_text(data, './/type'),
        severity: get_text(data, './/severity'),
        vulnerability_classifications: get_text(data, './/vulnerabilityClassifications'),
        references: get_text(data, './/references'),
        issue_background: get_text(data, './/issueBackground'),
        remediation_background: get_text(data, './/remediationBackground'),
        confidence: get_text(data, './/confidence'),
        # WaOccurrence
        host: get_text(data, './/host'),
        ip: get_text(data, './/host/@ip'),
        path: get_text(data, './/path'),
        location: get_text(data, '//location'),
        request_response: get_text(data, './/requestresponse'),
        remediation_detail: get_text(data, './/remediationDetail'),
        issue_detail: get_text(data, './/issueDetail'),
        serial_number: get_text(data, './/serialNumber')
      )
    end

    def self.from_xml!(xml)
      from_dynamic!(Nokogiri::XML(xml, &:strict))
    end

    def to_dynamic
      {
        'name' => @name,
        'type' => @type,
        'severity' => @severity,
        'vulnerability_classifications' => @vulnerability_classifications,
        'references' => @references,
        'issue_background' => @issue_background,
        'remediation_background' => @remediation_background,
        'confidence' => @confidence,
        'host' => @host,
        'ip' => @ip,
        'path' => @path,
        'location' => @location,
        'request_response' => @request_response,
        'remediation_detail' => @remediation_detail,
        'issue_detail' => @issue_detail,
        'serial_number' => @serial_number
      }
    end

    def to_json(options = nil)
      JSON.generate(to_dynamic, options)
    end
  end

  attribute :issues, Types.Array(Burp::Issue)
  attribute :host, Types::String

  def self.from_dynamic!(data)
    issues_d = data.search('//issue')
    new(
      issues: issues_d.map { |x| Burp::Issue.from_dynamic!(x) },
      host: get_text(issues_d.first, './/host')
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'issues' => @issues.map(&:to_dynamic),
      'host' => @host
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
