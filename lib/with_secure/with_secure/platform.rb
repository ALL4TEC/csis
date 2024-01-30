# frozen_string_literal: true

require 'common/types'
require 'common/xml'

module Types
  include Common::Types
end

class WithSecure::Platform < Dry::Struct
  extend Common::Xml

  # <host scanname="172.31.250.51" friendlyname="172.31.250.51"
  # scanId="ea2eaf5c-e4db-4474-9de3-0ef7907515dd" assetid="b507eb69-b475-4343-a28e-0fc642dd455b"
  # assetriskscore="9" importance="0" internetexposure="false">
  #  <title>172.31.250.51</title>
  #  <os></os>
  #  <ports>
  #   <port></port>
  #  </ports>
  #  <vulnerabilities>
  #   <vulnerability></vulnerability>
  #  </vulnerabilities>
  class Host < Dry::Struct
    extend Common::Xml

    # <port>
    #  <number>2049</number>
    #  <protocol>tcp</protocol>
    #  <state>open</state>
    #  <service>nfs</service>
    #  <banner></banner>
    #  <verifiedservice>rpc-nfs_acl</verifiedservice>
    # </port>
    class Port < Dry::Struct
      extend Common::Xml

      attribute :number, Types::String
      attribute :protocol, Types::String
      attribute :state, Types::String
      attribute :service, Types::String
      attribute :banner, Types::String
      attribute :verified_service, Types::String

      def self.from_dynamic!(data)
        new(
          number: get_text(data, './/number'),
          protocol: get_text(data, './/protocol'),
          state: get_text(data, './/state'),
          service: get_text(data, './/service'),
          banner: get_text(data, './/banner'),
          verified_service: get_text(data, './/verifiedservice')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'number' => @number,
          'protocol' => @protocol,
          'state' => @state,
          'service' => @service,
          'banner' => @banner,
          'verified_service' => @verified_service
        }
      end

      def to_json(options = nil)
        JSON.generate(to_dynamic, options)
      end
    end

    # <vulnerability risklevel="3" old="true">
    #  <id>11111</id>
    #  <port>52901</port>
    #  <protocol>tcp</protocol>
    #  <name>RPC Services Enumeration</name>
    #  <additionalinfo>The following RPC services are available on TCP port 52901:
    # - program: 100024 (status), version: 1</additionalinfo>
    #  <riskfactor>Information</riskfactor>
    #  <guid>ED0FDC4EFF02C6A0CF1493159DB5FD</guid>
    #  <risklevel>3</risklevel>
    #  <status>4a345238-287c-46c6-9eb6-7bf53ecbfd31</status>
    #  <localkey>1</localkey> -> vuln index
    #  <potential>false</potential>
    #  <firstseenon>12/5/2023 4:55:01 pm</firstseenon>
    # </vulnerability>
    class Vulnerability < Dry::Struct
      extend Common::Xml

      attribute :id, Types::String
      attribute :port, Types::String
      attribute :protocol, Types::String
      attribute :name, Types::String
      attribute :additional_info, Types::String
      attribute :risk_factor, Types::String
      attribute :guid, Types::String
      attribute :risk_level, Types::String
      attribute :status, Types::String
      attribute :local_key, Types::String
      attribute :potential, Types::String
      attribute :first_seen_on, Types::String

      def self.from_dynamic!(data)
        new(
          id: get_text(data, './/id'),
          port: get_text(data, './/port'),
          protocol: get_text(data, './/protocol'),
          name: get_text(data, './/name'),
          additional_info: get_text(data, './/additionalinfo'),
          risk_factor: get_text(data, './/riskfactor'),
          guid: get_text(data, './/guid'),
          risk_level: get_text(data, './/risklevel'),
          status: get_text(data, './/status'),
          local_key: get_text(data, './/localkey'),
          potential: get_text(data, './/potential'),
          first_seen_on: get_text(data, './/firstseenon')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'id' => @id,
          'port' => @port,
          'protocol' => @protocol,
          'name' => @name,
          'additional_info' => @additional_info,
          'risk_factor' => @risk_factor,
          'guid' => @guid,
          'risk_level' => @risk_level,
          'status' => @status,
          'local_key' => @local_key,
          'potential' => @potential,
          'first_seen_on' => @first_seen_on
        }
      end

      def to_json(options = nil)
        JSON.generate(to_dynamic, options)
      end
    end

    attribute :title, Types::String
    attribute :scan_name, Types::String
    attribute :friendly_name, Types::String
    attribute :scan_id, Types::String
    attribute :asset_id, Types::String
    attribute :asset_risk_score, Types::String
    attribute :importance, Types::String
    attribute :internet_exposure, Types::String
    attribute :ports, Types::Array(WithSecure::Platform::Host::Port)
    attribute :vulnerabilities, Types::Array(WithSecure::Platform::Host::Vulnerability)

    def self.from_dynamic!(data)
      ports_d = data.search('.//ports/port')
      vulnerabilities_d = data.search('.//vulnerabilities/vulnerability')
      new(
        title: get_text(data, './/title'),
        scan_name: get_attr_value(data, './@scanname'),
        friendly_name: get_attr_value(data, './@friendlyname'),
        scan_id: get_attr_value(data, './@scanId'),
        asset_id: get_attr_value(data, './@assetid'),
        asset_risk_score: get_attr_value(data, './@assetriskscore'),
        importance: get_attr_value(data, './@importance'),
        internet_exposure: get_attr_value(data, './@internetexposure'),
        ports: ports_d.map { |x| Port.from_dynamic!(x) },
        vulnerabilities: vulnerabilities_d.map { |x| Vulnerability.from_dynamic!(x) }
      )
    end

    def self.from_xml!(xml)
      from_dynamic!(Nokogiri::XML(xml, &:strict))
    end

    def to_dynamic
      {
        'title' => @title,
        'scan_name' => @scan_name,
        'friendly_name' => @friendly_name,
        'scan_id' => @scan_id,
        'asset_id' => @asset_id,
        'asset_risk_score' => @asset_risk_score,
        'importance' => @importance,
        'internet_exposure' => @internet_exposure,
        'ports' => @ports.map(&:to_dynamic),
        'vulnerabilities' => @vulnerabilities.map(&:to_dynamic)
      }
    end

    def to_json(options = nil)
      JSON.generate(to_dynamic, options)
    end
  end

  attribute :hosts, Types::Array(WithSecure::Platform::Host)

  def self.from_dynamic!(data)
    new(
      hosts: data.search('.//host').map { |x| WithSecure::Platform::Host.from_dynamic!(x) }
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'hosts' => @hosts.map(&:to_dynamic)
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
