# frozen_string_literal: true

require 'test_helper'
require 'qualys'
require 'qualys_wa'

class QualysWaTest < ActionDispatch::IntegrationTest
  test 'QualysWa::Scan can be instanciated' do
    s = QualysWa::Scan.new(Nokogiri::XML(YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/QualysWa_Scan.txt',
      permitted_classes: [
        QualysWa::Scan,
        QualysWa::WebApp,
        ActiveSupport::TimeWithZone,
        Time,
        ActiveSupport::TimeZone
      ]
    ).as_json.to_xml(dasherize: false)))
    assert s.instance_of?(QualysWa::Scan)
  end

  test 'QualysWa::Vulnerability can be instanciated' do
    v = QualysWa::Vulnerability.new(Nokogiri::XML(YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/QualysWa_Vulnerability.txt',
      permitted_classes: [
        Qualys::Vulnerability, # fixture is based on this class
        ActiveSupport::TimeWithZone,
        Time,
        ActiveSupport::TimeZone,
        Qualys::ExploitSource,
        Qualys::Exploit
      ]
    ).as_json.to_xml(dasherize: false)))
    assert v.instance_of?(QualysWa::Vulnerability)
  end

  test 'QualysWa::ScanResult can be instantiated' do
    result = YAML.safe_load_file(
      'test/fixtures/files/JobTestValues/QualysWa_ScanResult.txt',
      permitted_classes: [
        QualysWa::ScanResult,
        QualysWa::ScanTest
      ]
    )
    assert result.instance_of?(QualysWa::ScanResult)
  end

  test 'QualysWa::WebApp can be instantiated' do
    webapp = QualysWa::Webapp.new(Nokogiri::XML(YAML.safe_load_file(
      'test/fixtures/files/JobTestValues/QualysWa_Webapp.txt',
      permitted_classes: [
        QualysWa::Webapp
      ]
    ).as_json.to_xml(dasherize: false)))
    assert webapp.instance_of?(QualysWa::Webapp)
  end
end
