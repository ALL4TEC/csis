# frozen_string_literal: true

require 'common/types'
require 'common/xml'

module Types
  include Common::Types
end

class WithSecure::ReportInfo < Dry::Struct
  extend Common::Xml

  # <filtersettings>
  #  <includeallvulnstatuses>False</includeallvulnstatuses>
  #  <tags />
  #  <tagsscan />
  #  <scopeType>2</scopeType>
  #  <showstatusnamesonreport>True</showstatusnamesonreport>
  #  <showauditornotes>True</showauditornotes>
  #  <showtags>True</showtags>
  #  <showchangeindicator>True</showchangeindicator>
  #  <includeimages>False</includeimages>
  #  <includerefs>True</includerefs>
  #  <includeexploitable>False</includeexploitable>
  #  <includepotential>True</includepotential>
  #  <showresponsibleperson>False</showresponsibleperson>
  #  <responsiblepeople />
  #  <includelastreportsforscans />
  #  <includeassets />
  #  <vulnerabilityfamiliesall>True</vulnerabilityfamiliesall>
  #  <wsvulnerabilitycategoriesall>True</wsvulnerabilitycategoriesall>
  # </filtersettings>
  class FilterSettings < Dry::Struct
    extend Common::Xml

    # <vulnsstates>
    #  <status checked="1" name="Unattended"
    # title="No actions have been taken on this vulnerability" graysOut="false"
    # counter="1">4a345238-287c-46c6-9eb6-7bf53ecbfd31</status>
    #  ...
    # </vulnsstates>
    class VulnStatus < Dry::Struct
      extend Common::Xml

      attribute :uuid, Types::String
      attribute :checked, Types::String
      attribute :name, Types::String
      attribute :title, Types::String

      def self.from_dynamic!(data)
        new(
          uuid: get_text(data, '.'),
          checked: get_attr_value(data, './@checked'),
          name: get_attr_value(data, './@name'),
          title: get_attr_value(data, './@title')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'uuid' => @uuid,
          'checked' => @checked,
          'name' => @name,
          'title' => @title
        }
      end

      def to_json(options = nil)
        JSON.generate(to_dynamic, options)
      end
    end

    # <severitylevel>
    #  <info>True</info>
    #  <low>True</low>
    #  <medium>True</medium>
    #  <high>True</high>
    #  <critical>True</critical>
    # </severitylevel>
    class SeverityLevel < Dry::Struct
      extend Common::Xml

      attribute :info, Types::String
      attribute :low, Types::String
      attribute :medium, Types::String
      attribute :high, Types::String
      attribute :critical, Types::String

      def self.from_dynamic!(data)
        new(
          info: get_text(data, './/info'),
          low: get_text(data, './/low'),
          medium: get_text(data, './/medium'),
          high: get_text(data, './/high'),
          critical: get_text(data, './/critical')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'info' => @info,
          'low' => @low,
          'medium' => @medium,
          'high' => @high,
          'critical' => @critical
        }
      end

      def to_json(options = nil)
        JSON.generate(to_dynamic, options)
      end
    end

    # <exploitlevel>
    #  <includelocallyexploitablevulns>True</includelocallyexploitablevulns>
    #  <includeremotelyexploitablevulns>True</includeremotelyexploitablevulns>
    #  <includeallvulns>True</includeallvulns>
    # </exploitlevel>
    class ExploitLevel < Dry::Struct
      extend Common::Xml

      attribute :include_locally_exploitable_vulns, Types::String.optional
      attribute :include_remotely_exploitable_vulns, Types::String.optional
      attribute :include_all_vulns, Types::String.optional

      def self.from_dynamic!(data)
        new(
          include_locally_exploitable_vulns: get_text(data, './/includelocallyexploitablevulns'),
          include_remotely_exploitable_vulns: get_text(data, './/includeremotelyexploitablevulns'),
          include_all_vulns: get_text(data, './/includeallvulns')
        )
      end

      def self.from_xml!(xml)
        from_dynamic!(Nokogiri::XML(xml, &:strict))
      end

      def to_dynamic
        {
          'include_locally_exploitable_vulns' => @include_locally_exploitable_vulns,
          'include_remotely_exploitable_vulns' => @include_remotely_exploitable_vulns,
          'include_all_vulns' => @include_all_vulns
        }
      end

      def to_json(options = nil)
        JSON.generate(to_dynamic, options)
      end
    end

    attribute :vuln_statuses, Types::Array(WithSecure::ReportInfo::FilterSettings::VulnStatus)
    attribute :include_all_vuln_statuses, Types::String.optional
    attribute :scope_type, Types::String.optional
    attribute :severity_level, WithSecure::ReportInfo::FilterSettings::SeverityLevel
    attribute :show_status_names_on_report, Types::String.optional
    attribute :show_audit_or_notes, Types::String.optional
    attribute :show_tags, Types::String.optional
    attribute :show_change_indicator, Types::String.optional
    attribute :include_images, Types::String.optional
    attribute :include_refs, Types::String.optional
    attribute :include_exploitable, Types::String.optional
    attribute :include_potential, Types::String.optional
    attribute :show_responsible_person, Types::String.optional
    attribute :include_groups, Types::Array(Types::String)
    attribute :exploit_level, WithSecure::ReportInfo::FilterSettings::ExploitLevel
    attribute :vulnerability_families_all, Types::String.optional
    attribute :vulnerability_families, Types::Array(Types::String)
    attribute :ws_vulnerability_categories_all, Types::String.optional
    attribute :ws_vulnerability_categories, Types::Array(Types::String)

    def self.from_dynamic!(data)
      new(
        vuln_statuses: data.search('.//status').map do |x|
                         WithSecure::ReportInfo::FilterSettings::VulnStatus.from_dynamic!(x)
                       end,
        include_all_vuln_statuses: get_text(data, './/includeallvulnstatuses'),
        scope_type: get_text(data, './/scopeType'),
        severity_level: SeverityLevel.from_dynamic!(data.search('.//severitylevel')),
        show_status_names_on_report: get_text(data, './/showstatusnamesonreport'),
        show_audit_or_notes: get_text(data, './/showauditornotes'),
        show_tags: get_text(data, './/showtags'),
        show_change_indicator: get_text(data, './/showchangeindicator'),
        include_images: get_text(data, './/includeimages'),
        include_refs: get_text(data, './/includerefs'),
        include_exploitable: get_text(data, './/includeexploitable'),
        include_potential: get_text(data, './/includepotential'),
        show_responsible_person: get_text(data, './/showresponsibleperson'),
        include_groups: data.search('.//group').map { |x| get_text(x, '.') },
        exploit_level: ExploitLevel.from_dynamic!(data.search('.//exploitlevel')),
        vulnerability_families_all: get_text(data, './/vulnerabilityfamiliesall'),
        vulnerability_families: data.search('.//family').map { |x| get_text(x, '.') },
        ws_vulnerability_categories_all: get_text(data, './/wsvulnerabilitycategoriesall'),
        ws_vulnerability_categories: data.search('.//category').map { |x| get_text(x, '.') }
      )
    end

    def self.from_xml!(xml)
      from_dynamic!(Nokogiri::XML(xml, &:strict))
    end

    def to_dynamic
      {
        'vuln_statuses' => @vuln_statuses,
        'include_all_vuln_statuses' => @include_all_vuln_statuses,
        'scope_type' => @scope_type,
        'severity_level' => @severity_level,
        'show_status_names_on_report' => @show_status_names_on_report,
        'show_audit_or_notes' => @show_audit_or_notes,
        'show_tags' => @show_tags,
        'show_change_indicator' => @show_change_indicator,
        'include_images' => @include_images,
        'include_refs' => @include_refs,
        'include_exploitable' => @include_exploitable,
        'include_potential' => @include_potential,
        'show_responsible_person' => @show_responsible_person,
        'include_groups' => @include_groups.map(&:to_dynamic),
        'exploit_level' => @exploit_level,
        'vulnerability_families_all' => @vulnerability_families_all,
        'vulnerability_families' => @vulnerability_families.map(&:to_dynamic),
        'ws_vulnerability_categories_all' => @ws_vulnerability_categories_all,
        'ws_vulnerability_categories' => @ws_vulnerability_categories.map(&:to_dynamic)
      }
    end

    def to_json(options = nil)
      JSON.generate(to_dynamic, options)
    end
  end

  attribute :created_on, Types::String.optional
  attribute :created_on_date, Types::String.optional
  attribute :timezone, Types::String.optional
  attribute :created_by, Types::String.optional
  attribute :cvss_version, Types::String.optional
  attribute :filter_settings, WithSecure::ReportInfo::FilterSettings
  attribute :start_date, Types::String.optional
  attribute :end_date, Types::String.optional

  def self.from_dynamic!(data)
    new(
      created_on: get_text(data, './/createdon'),
      created_on_date: get_text(data, './/createdOnDate'),
      timezone: get_text(data, './/timezone'),
      created_by: get_text(data, './/createdby'),
      cvss_version: get_text(data, './/cvssversion'),
      filter_settings: FilterSettings.from_dynamic!(data.search('.//filtersettings')),
      start_date: get_text(data, './/startdate'),
      end_date: get_text(data, './/enddate')
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'created_on' => @created_on,
      'created_on_date' => @created_on_date,
      'timezone' => @timezone,
      'created_by' => @created_by,
      'cvss_version' => @cvss_version,
      'filter_settings' => @filter_settings.to_dynamic,
      'start_date' => @start_date,
      'end_date' => @end_date
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
