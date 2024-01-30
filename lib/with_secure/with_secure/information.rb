# frozen_string_literal: true

require 'common/types'
require 'common/xml'

module Types
  include Common::Types
end

class WithSecure::Information < Dry::Struct
  extend Common::Xml

  # <host scanname="10.100.100.100" friendlyname="10.100.100.100"
  # scanId="a8cf1f70-f524-4021-aaa2-c511a592a7cc" scandomain=""
  # reportId="d8d661a3-ca06-4867-9d53-02671299362c" groupId="1cb9f703-5e05-43fb-97db-add1163a9c6b">
  #   <title>10.100.100.100</title>
  #   <dns />
  #   <scanstarttime>05-12-2023 19:29:50</scanstarttime>
  #   <scanendtime>05-12-2023 19:37:03</scanendtime>
  #   <head>
  #     <title />
  #     <data />
  #   </head>
  #   <createdon>05-12-2023 19:37:04</createdon>
  # </host>
  class Host < Dry::Struct
    extend Common::Xml

    # <whois>
    #  <title>10.100.100.100</title>
    #  <data />
    #  <name>Unknown</name>
    # </whois>
    class Whois < Dry::Struct
      extend Common::Xml

      attribute :title, Types::String
      attribute :name, Types::String

      def self.from_dynamic!(data)
        new(
          title: get_text(data, './/title'),
          name: get_text(data, './/name')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'title' => @title,
          'name' => @name
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
    attribute :scan_domain, Types::String
    attribute :report_id, Types::String
    attribute :group_id, Types::String
    attribute :whois, WithSecure::Information::Host::Whois
    attribute :scan_start_time, Types::String
    attribute :scan_end_time, Types::String
    attribute :created_on, Types::String

    def self.from_dynamic!(data)
      new(
        title: get_text(data, './/title'),
        scan_name: get_attr_value(data, './@scanname'),
        friendly_name: get_attr_value(data, './@friendlyname'),
        scan_id: get_attr_value(data, './@scanId'),
        scan_domain: get_attr_value(data, './@scandomain'),
        report_id: get_attr_value(data, './@reportId'),
        group_id: get_attr_value(data, './@groupId'),
        whois: Whois.from_dynamic!(data.search('.//whois')),
        scan_start_time: get_text(data, './/scanstarttime'),
        scan_end_time: get_text(data, './/scanendtime'),
        created_on: get_text(data, './/createdon')
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
        'scan_domain' => @scan_domain,
        'report_id' => @report_id,
        'group_id' => @group_id,
        'whois' => @whois.map(&:to_dynamic),
        'scan_start_time' => @scan_start_time,
        'scan_end_time' => @scan_end_time,
        'created_on' => @created_on
      }
    end

    def to_json(options = nil)
      JSON.generate(to_dynamic, options)
    end
  end

  attribute :hosts, Types::Array(WithSecure::Information::Host)

  def self.from_dynamic!(data)
    hosts_d = data.search('.//host')
    new(
      hosts: hosts_d.map { |x| Host.from_dynamic!(x) }
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
