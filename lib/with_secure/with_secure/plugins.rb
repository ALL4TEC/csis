# frozen_string_literal: true

require 'common/types'
require 'common/xml'

module Types
  include Common::Types
end

class WithSecure::Plugins < Dry::Struct
  extend Common::Xml

  # <platform>
  #   <plugin></plugin>
  # </platform>
  class Platform < Dry::Struct
    extend Common::Xml

    class Plugin < Dry::Struct
      extend Common::Xml

      # <xrefs>
      #   <xref name="" url="">XXX</xref>
      # </xrefs>
      class XRef < Dry::Struct
        extend Common::Xml

        attribute :description, Types::String
        attribute :name, Types::String
        attribute :url, Types::String

        def self.from_dynamic!(data)
          new(
            description: get_text(data, '.'),
            name: get_attr_value(data, './@name'),
            url: get_attr_value(data, './@url')
          )
        end

        def self.from_xml!(xml)
          from_dynamic!(Nokogiri::XML(xml, &:strict))
        end

        def to_dynamic
          {
            'description' => @description,
            'name' => @name,
            'url' => @url
          }
        end

        def to_json(options = nil)
          JSON.generate(to_dynamic, options)
        end
      end

      # <attributes>
      #   <attribute name="XXX"></attribute>
      # </attributes>
      class Attributes < Dry::Struct
        extend Common::Xml

        attribute :synopsis, Types::String
        attribute :description, Types::String
        attribute :solution, Types::String
        attribute :dos, Types::String
        attribute :trust, Types::String
        attribute :cvss_cvss_v3_base_score, Types::String
        attribute :cvss_v3_vector, Types::String.optional

        def self.from_dynamic!(data)
          new(
            synopsis: get_text(data, './/attribute[@name="synopsis"]'),
            description: get_text(data, './/attribute[@name="description"]'),
            solution: get_text(data, './/attribute[@name="solution"]'),
            dos: get_text(data, './/attribute[@name="DOS"]'),
            trust: get_text(data, './/attribute[@name="trust"]'),
            cvss_cvss_v3_base_score: get_text(data,
              './/attribute[@name="cvss_cvss_V3_base_score"]'),
            cvss_v3_vector: get_text(data, './/attribute[@name="cvss_V3_vector"]')
          )
        end

        def self.from_xml!(xml)
          from_dynamic!(Nokogiri::XML(xml, &:strict))
        end

        def to_dynamic
          {
            'synopsis' => @synopsis,
            'description' => @description,
            'solution' => @solution,
            'dos' => @dos,
            'trust' => @trust,
            'cvss_cvss_v3_base_score' => @cvss_cvss_v3_base_score,
            'cvss_v3_vector' => @cvss_v3_vector
          }
        end

        def to_json(options = nil)
          JSON.generate(to_dynamic, options)
        end
      end

      # <tags>
      #   <tag technical-name="" source="">XXX</tag>
      # </tags>
      class Tag < Dry::Struct
        extend Common::Xml

        attribute :technical_name, Types::String
        attribute :source, Types::String
        attribute :value, Types::String

        def self.from_dynamic!(data)
          new(
            technical_name: get_attr_value(data, './@technical-name'),
            source: get_attr_value(data, './@source'),
            value: get_text(data, '.')
          )
        end

        def self.from_xml!(xml)
          from_dynamic!(Nokogiri::XML(xml, &:strict))
        end

        def to_dynamic
          {
            'technical_name' => @technical_name,
            'source' => @source,
            'value' => @value
          }
        end

        def to_json(options = nil)
          JSON.generate(to_dynamic, options)
        end
      end

      attribute :id, Types::String
      attribute :script_version, Types::String
      attribute :family, Types::String
      attribute :summary, Types::String
      attribute :bugtraq_ids, Types::Array(Types::String)
      attribute :cve_ids, Types::Array(Types::String)
      attribute :exploits, Types::Array(Types::String)
      attribute :xrefs, Types::Array(WithSecure::Plugins::Platform::Plugin::XRef)
      attribute :attributs, WithSecure::Plugins::Platform::Plugin::Attributes
      attribute :tags, Types::Array(WithSecure::Plugins::Platform::Plugin::Tag)
      attribute :exploitable, Types::String

      def self.from_dynamic!(data)
        new(
          id: get_text(data, './/id'),
          script_version: get_text(data, './/script_version'),
          family: get_text(data, './/family'),
          summary: get_text(data, './/summary'),
          bugtraq_ids: data.search('.//bugtraqids/bugtraqid').map { |x| get_text(x, '.') },
          cve_ids: data.search('.//cveids/cveid').map { |x| get_text(x, '.') },
          exploits: data.search('.//exploits/exploit').map { |x| get_text(x, '.') },
          xrefs: data.search('.//xrefs/xref').map { |x| XRef.from_dynamic!(x) },
          attributs: Attributes.from_dynamic!(data.search('.//attributes')),
          tags: data.search('.//tags/tag').map { |x| Tag.from_dynamic!(x) },
          exploitable: get_text(data, './/exploitable')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'id' => @id,
          'script_version' => @script_version,
          'family' => @family,
          'summary' => @summary,
          'bugtraq_ids' => @bugtraq_ids,
          'cve_ids' => @cve_ids,
          'xrefs' => @xrefs,
          'attributs' => @attributs,
          'tags' => @tags,
          'exploitable' => @exploitable
        }
      end

      def to_json(options = nil)
        JSON.generate(to_dynamic, options)
      end
    end

    attribute :plugins, Types::Array(WithSecure::Plugins::Platform::Plugin)

    def self.from_dynamic!(data)
      new(
        plugins: data.search('.//plugin').map { |x| Plugin.from_dynamic!(x) }
      )
    end

    def self.from_xml!(xml)
      from_dynamic!(Nokogiri::XML(xml, &:strict))
    end

    def to_dynamic
      {
        'plugins' => @plugins.map(&:to_dynamic)
      }
    end

    def to_json(options = nil)
      JSON.generate(to_dynamic, options)
    end
  end

  attribute :platform, WithSecure::Plugins::Platform

  def self.from_dynamic!(data)
    new(
      platform: Platform.from_dynamic!(data.search('.//platform'))
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'platform' => @platform
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
