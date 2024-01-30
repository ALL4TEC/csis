# frozen_string_literal: true

# This code may look unusually verbose for Ruby (and it is), but
# it performs some subtle and complex validation of JSON data.
#
# To parse this JSON, add 'dry-struct' and 'dry-types' gems, then do:
#
#   zaproxy = Zaproxy.from_json! "{…}"
#   puts zaproxy.site.first.alerts.first.instances.first
#
# If from_json! succeeds, the value returned matches the schema.

require 'json'
require 'common/types'

module Types
  include Common::Types
end

class Instance < Dry::Struct
  attribute :uri,      Types::String
  attribute :method1,  Types::String
  attribute :evidence, Types::String.optional
  attribute :param,    Types::String.optional

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      uri: data.fetch('uri'),
      method1: data.fetch('method'),
      evidence: data['evidence'],
      param: data['param']
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      'uri' => @uri,
      'method' => @method1,
      'evidence' => @evidence,
      'param' => @param
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class Alert < Dry::Struct
  attribute :pluginid,   Types::String
  attribute :alert,      Types::String
  attribute :alert_name, Types::String
  attribute :riskcode,   Types::String
  attribute :confidence, Types::String
  attribute :riskdesc,   Types::String
  attribute :desc,       Types::String
  attribute :instances,  Types.Array(Instance)
  attribute :count,      Types::String
  attribute :solution,   Types::String
  attribute :otherinfo,  Types::String.optional
  attribute :reference,  Types::String
  attribute :cweid,      Types::String
  attribute :wascid,     Types::String
  attribute :sourceid,   Types::String

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      pluginid: data.fetch('pluginid'),
      alert: data.fetch('alert'),
      alert_name: data.fetch('name'),
      riskcode: data.fetch('riskcode'),
      confidence: data.fetch('confidence'),
      riskdesc: data.fetch('riskdesc'),
      desc: data.fetch('desc'),
      instances: data.fetch('instances').map { |instance| Instance.from_dynamic!(instance) },
      count: data.fetch('count'),
      solution: data.fetch('solution'),
      otherinfo: data['otherinfo'],
      reference: data.fetch('reference'),
      cweid: data.fetch('cweid'),
      wascid: data.fetch('wascid'),
      sourceid: data.fetch('sourceid')
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      'pluginid' => @pluginid,
      'alert' => @alert,
      'name' => @alert_name,
      'riskcode' => @riskcode,
      'confidence' => @confidence,
      'riskdesc' => @riskdesc,
      'desc' => @desc,
      'instances' => @instances.map(&:to_dynamic),
      'count' => @count,
      'solution' => @solution,
      'otherinfo' => @otherinfo,
      'reference' => @reference,
      'cweid' => @cweid,
      'wascid' => @wascid,
      'sourceid' => @sourceid
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class Site < Dry::Struct
  attribute :site_name, Types::String
  attribute :host,      Types::String
  attribute :port,      Types::String
  attribute :ssl,       Types::String
  attribute :alerts,    Types.Array(Alert)

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      site_name: data.fetch('@name'),
      host: data.fetch('@host'),
      port: data.fetch('@port'),
      ssl: data.fetch('@ssl'),
      alerts: data.fetch('alerts').map { |alert| Alert.from_dynamic!(alert) }
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      '@name' => @site_name,
      '@host' => @host,
      '@port' => @port,
      '@ssl' => @ssl,
      'alerts' => @alerts.map(&:to_dynamic)
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end

class Zaproxy < Dry::Struct
  attribute :version,   Types::String
  attribute :generated, Types::String
  attribute :site,      Types.Array(Site)

  def self.from_dynamic!(data)
    data = Types::Hash[data]
    new(
      version: data.fetch('@version'),
      generated: data.fetch('@generated'),
      site: data.fetch('site').map { |site| Site.from_dynamic!(site) }
    )
  end

  def self.from_json!(json)
    from_dynamic!(JSON.parse(json))
  end

  def to_dynamic
    {
      '@version' => @version,
      '@generated' => @generated,
      'site' => @site.map(&:to_dynamic)
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
