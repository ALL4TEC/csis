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

class ReportItem < Dry::Struct
  extend Common::Xml

  attribute :plugin_family, Types::String.optional
  attribute :plugin_name, Types::String.optional
  attribute :plugin_id, Types::String.optional
  attribute :severity, Types::String.optional
  attribute :protocol, Types::String.optional
  attribute :svc_name, Types::String.optional
  attribute :port, Types::String.optional
  attribute :description, Types::String.optional
  attribute :fname, Types::String.optional
  attribute :plugin_modification_date, Types::String.optional
  attribute :plugin_type, Types::String.optional
  attribute :plugin_publication_date, Types::String.optional
  attribute :risk_factor, Types::String.optional
  attribute :script_version, Types::String.optional
  attribute :solution, Types::String.optional
  attribute :synopsis, Types::String.optional
  attribute :plugin_output, Types::String.optional
  attribute :see_also, Types::String.optional
  attribute :cve, Types::String.optional
  attribute :bid, Types::String.optional
  attribute :xrefs, Types::String.optional
  attribute :patch_publication_date, Types::String.optional
  attribute :cvss_vector, Types::String.optional
  attribute :cvss_base_score, Types::String.optional

  def self.from_dynamic!(data)
    new(
      plugin_family: get_attr_value(data, './@pluginFamily'),
      plugin_name: get_attr_value(data, './@pluginName'),
      plugin_id: get_attr_value(data, './@pluginID'),
      severity: get_attr_value(data, './@severity'),
      protocol: get_attr_value(data, './@protocol'),
      svc_name: get_attr_value(data, './@svc_name'),
      port: get_attr_value(data, './@port'),
      description: get_text(data, './/description'),
      fname: get_text(data, './/fname'),
      plugin_modification_date: get_text(data, './/plugin_modification_date'),
      plugin_type: get_text(data, './/plugin_type'),
      plugin_publication_date: get_text(data, './/plugin_publication_date'),
      risk_factor: get_text(data, './/risk_factor'),
      script_version: get_text(data, './/script_version'),
      solution: get_text(data, './/solution'),
      synopsis: get_text(data, './/synopsis'),
      plugin_output: get_text(data, './/plugin_output'),
      see_also: get_xpath(data, './/see_also')&.map(&:text),
      cve: get_text(data, './/cve'),
      bid: get_text(data, './/bid'),
      xrefs: get_xpath(data, './/xref')&.map(&:text),
      patch_publication_date: get_text(data, './/patch_publication_date'),
      cvss_vector: get_text(data, './/cvss_vector'),
      cvss_base_score: get_text(data, './/cvss_base_score')
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'plugin_family' => @plugin_family,
      'plugin_name' => @plugin_name,
      'plugin_id' => @plugin_id,
      'severity' => @severity,
      'protocol' => @protocol,
      'svc_name' => @svc_name,
      'port' => @port,
      'description' => @description,
      'fname' => @fname,
      'plugin_modification_date' => @plugin_modification_date,
      'plugin_type' => @plugin_type,
      'plugin_publication_date' => @plugin_publication_date,
      'risk_factor' => @risk_factor,
      'script_version' => @script_version,
      'solution' => @solution,
      'synopsis' => @synopsis,
      'plugin_output' => @plugin_output,
      'see_also' => @see_also,
      'cve' => @cve,
      'bid' => @bid,
      'xrefs' => @xrefs,
      'patch_publication_date' => @patch_publication_date,
      'cvss_vector' => @cvss_vector,
      'cvss_base_score' => @cvss_base_score
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class ReportHost < Dry::Struct
  extend Common::Xml

  attribute :name,                  Types::String.optional
  attribute :host_end_timestamp,    Types::String.optional
  attribute :operating_system,      Types::String.optional
  attribute :host_netbios,          Types::String.optional
  attribute :host_fqdn,             Types::String.optional
  attribute :host_rdns,             Types::String.optional
  attribute :host_ip,               Types::String.optional
  attribute :host_start_timestamp,  Types::String.optional
  attribute :report_items,          Types.Array(ReportItem)

  def self.from_dynamic!(data)
    new(
      name: get_text(data, './@name'),
      host_end_timestamp: get_text(data, ".//tag[@name='HOST_END_TIMESTAMP']"),
      operating_system: get_text(data, ".//tag[@name='operating-system']"),
      host_netbios: get_text(data, ".//tag[@name='netbios-name']"),
      host_fqdn: get_text(data, ".//tag[@name='host-fqdn']"),
      host_rdns: get_text(data, ".//tag[@name='host-rdns']"),
      host_ip: get_text(data, ".//tag[@name='host-ip']"),
      host_start_timestamp: get_text(data, ".//tag[@name='HOST_START_TIMESTAMP']"),
      report_items: data.search('.//ReportItem').map { |x| ReportItem.from_dynamic!(x) }
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'name' => @name,
      'host_end_timestamp' => @host_end_timestamp,
      'operating_system' => @operating_system,
      'host_netbios' => @host_netbios,
      'host_fqdn' => @host_fqdn,
      'host_rdns' => @host_rdns,
      'host_ip' => @host_ip,
      'host_start_timestamp' => @host_start_timestamp,
      'report_items' => @report_items
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class Nessus < Dry::Struct
  extend Common::Xml

  attribute :report_host, ReportHost

  def self.from_dynamic!(data)
    new(
      report_host: ReportHost.from_dynamic!(data.search('//ReportHost'))
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'report_host' => @report_host
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
