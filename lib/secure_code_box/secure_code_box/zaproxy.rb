# frozen_string_literal: true

# This code may look unusually verbose for Ruby (and it is), but
# it performs some subtle and complex validation of JSON data.
#
# To parse this JSON, add 'dry-struct' and 'dry-types' gems, then do:
#
#   zaproxy = Zaproxy.from_json! "{…}"
#   puts zaproxy.findings.first.attributes.zap_finding_urls.first.uri
#
# If from_json! succeeds, the value returned matches the schema.

require 'json'
require 'common/types'

module Types
  include Common::Types

  Severity = Strict::String.enum('HIGH', 'INFORMATIONAL', 'LOW', 'MEDIUM')
end

class ZapFindingURL < Dry::Struct
  attribute :uri,                    Types::String
  attribute :zap_finding_url_method, Types::String
  attribute :evidence,               Types::String.optional
  attribute :param,                  Types::String.optional
  attribute :attack,                 Types::String.optional
  attribute :otherinfo,              Types::String.optional # Same as zap_otherinfo

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      uri: data.fetch('uri'),
      zap_finding_url_method: data.fetch('method'),
      evidence: data['evidence'],
      param: data['param'],
      attack: data['attack'],
      otherinfo: data['otherinfo']
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      'uri' => @uri,
      'method' => @zap_finding_url_method,
      'evidence' => @evidence,
      'param' => @param,
      'attack' => @attack,
      'otherinfo' => @otherinfo
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class ZapAttributes < Dry::Struct
  attribute :hostname,         Types::String
  attribute :port,             Types::String
  attribute :zap_confidence,   Types::String
  attribute :zap_count,        Types::String
  attribute :zap_solution,     Types::String.optional
  attribute :zap_otherinfo,    Types::String.optional
  attribute :zap_reference,    Types::String.optional
  attribute :zap_cweid,        Types::String.optional
  attribute :zap_wascid,       Types::String.optional
  attribute :zap_riskcode,     Types::String
  attribute :zap_pluginid,     Types::String
  attribute :zap_finding_urls, Types.Array(ZapFindingURL)

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      hostname: data.fetch('hostname'),
      port: data.fetch('port'),
      zap_confidence: data.fetch('zap_confidence'),
      zap_count: data.fetch('zap_count'),
      zap_solution: data.fetch('zap_solution'),
      zap_otherinfo: data.fetch('zap_otherinfo'),
      zap_reference: data.fetch('zap_reference'),
      zap_cweid: data.fetch('zap_cweid'),
      zap_wascid: data.fetch('zap_wascid'),
      zap_riskcode: data.fetch('zap_riskcode'),
      zap_pluginid: data.fetch('zap_pluginid'),
      zap_finding_urls: data.fetch('zap_finding_urls').map { |x| ZapFindingURL.from_dynamic!(x) }
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      'hostname' => @hostname,
      'port' => @port,
      'zap_confidence' => @zap_confidence,
      'zap_count' => @zap_count,
      'zap_solution' => @zap_solution,
      'zap_otherinfo' => @zap_otherinfo,
      'zap_reference' => @zap_reference,
      'zap_cweid' => @zap_cweid,
      'zap_wascid' => @zap_wascid,
      'zap_riskcode' => @zap_riskcode,
      'zap_pluginid' => @zap_pluginid,
      'zap_finding_urls' => @zap_finding_urls.map(&:to_dynamic)
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

module Severity
  HIGH          = 'HIGH'
  INFORMATIONAL = 'INFORMATIONAL'
  LOW           = 'LOW'
  MEDIUM        = 'MEDIUM'
end

class Finding < Dry::Struct
  attribute :finding_name, Types::String
  attribute :description,  Types::String
  attribute :category,     Types::String
  attribute :location,     Types::String
  attribute :osi_layer,    Types::String
  attribute :severity,     Types::Severity
  attribute :mitigation,   Types::String # Same as zap_solution
  attribute :finding_attributes, ZapAttributes
  attribute :id, Types::String

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      finding_name: data.fetch('name'),
      description: data.fetch('description'),
      category: data.fetch('category'),
      location: data.fetch('location'),
      osi_layer: data.fetch('osi_layer'),
      severity: data.fetch('severity'),
      mitigation: data.fetch('mitigation'),
      finding_attributes: ZapAttributes.from_dynamic!(data.fetch('attributes')),
      id: data.fetch('id')
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      'name' => @finding_name,
      'description' => @description,
      'category' => @category,
      'location' => @location,
      'osi_layer' => @osi_layer,
      'severity' => @severity,
      'mitigation' => @mitigation,
      'attributes' => @finding_attributes.to_dynamic,
      'id' => @id
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class SecureCodeBox::Zaproxy < Dry::Struct
  attribute :findings, Types.Array(Finding)

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      findings: data.fetch('findings').map { |x| Finding.from_dynamic!(x) }
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      'findings' => @findings.map(&:to_dynamic)
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
