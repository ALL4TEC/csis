# frozen_string_literal: true

require 'test_helper'
require 'qualys'
require 'qualys_wa'

class QualysTest < ActionDispatch::IntegrationTest
  test 'Qualys::Scan can be instanciated' do
    s = Qualys::Scan.new(Nokogiri::XML(YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/Qualys_Scan.txt',
      permitted_classes: [
        Qualys::Scan,
        Time,
        ActiveSupport::TimeWithZone,
        ActiveSupport::TimeZone
      ]
    ).as_json.to_xml(dasherize: false)))
    assert s.instance_of?(Qualys::Scan)
  end

  test 'Qualys::Vulnerability can be instanciated' do
    v = Qualys::Vulnerability.new(Nokogiri::XML(YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/Qualys_Vulnerability.txt',
      permitted_classes: [
        Qualys::Vulnerability,
        Time,
        ActiveSupport::TimeWithZone,
        ActiveSupport::TimeZone,
        Qualys::ExploitSource,
        Qualys::Exploit
      ]
    ).as_json.to_xml(dasherize: false)))
    assert v.instance_of?(Qualys::Vulnerability)
  end

  test 'Qualys::ScanResult can be instantiated' do
    content = YAML.safe_load_file(
      'test/fixtures/files/JobTestValues/Qualys_ScanResult.txt',
      permitted_classes: [
        Qualys::ScanResult,
        Qualys::ScanTest
      ]
    )
    assert content.instance_of?(Qualys::ScanResult)
  end
end
