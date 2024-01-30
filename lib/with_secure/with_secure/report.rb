# frozen_string_literal: true

require 'common/types'
require 'common/xml'

module Types
  include Common::Types
end

class WithSecure::Report < Dry::Struct
  extend Common::Xml

  attribute :title, Types::String
  attribute :description, Types::String
  attribute :report_info, WithSecure::ReportInfo
  attribute :information, WithSecure::Information
  attribute :platform, WithSecure::Platform
  attribute :plugins, WithSecure::Plugins

  def self.from_dynamic!(data)
    report_info_d = data.search('//section[@type="reportinfo"]')
    information_d = data.search('//section[@type="information"]')
    platform_d = data.search('//section[@type="platform"]')
    plugins_d = data.search('//section[@type="plugins"]')
    new(
      title: get_text(data, './/title'),
      description: get_text(data, './/description'),
      report_info: WithSecure::ReportInfo.from_dynamic!(report_info_d),
      information: WithSecure::Information.from_dynamic!(information_d),
      platform: WithSecure::Platform.from_dynamic!(platform_d),
      plugins: WithSecure::Plugins.from_dynamic!(plugins_d)
    )
  end

  def self.from_xml!(xml)
    from_dynamic!(Nokogiri::XML(xml, &:strict))
  end

  def to_dynamic
    {
      'title' => @title,
      'description' => @description,
      'report_info' => @report_info.map(&:to_dynamic),
      'information' => @information.map(&:to_dynamic),
      'platform' => @platform.map(&:to_dynamic),
      'plugins' => @plugins.map(&:to_dynamic)
    }
  end

  def to_json(options = nil)
    JSON.generate(to_dynamic, options)
  end
end
