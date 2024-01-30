# frozen_string_literal: true

require 'test_helper'
require 'with_secure'

class WithSecureTest < ActionDispatch::IntegrationTest
  test 'WithSecure::Report can be instanciated' do
    file_content = File.read('test/fixtures/files/LibTestValues/with_secure_sample_vm_scan.xml')
    scan_data = WithSecure::Report.from_xml!(file_content)
    assert scan_data.instance_of?(WithSecure::Report)
    all_vulns_count = 0
    # List all vulnerabilities data
    scan_data.platform.hosts.each do |ws_host|
      vulns_count = ws_host.vulnerabilities.count
      all_vulns_count += vulns_count
      # puts "#{ws_host.title}, #{puts vulns_count}"
      # ws_host.vulnerabilities.each do |ws_vuln|
      #   puts "#{ws_vuln.risk_factor}, #{ws_vuln.risk_level}, #{ws_vuln.potential}"
      # end
    end
    assert_equal 2046, all_vulns_count
    vulns_per_severity = {
      critical: [],
      high: [],
      medium: [],
      low: [],
      trivial: []
    }
    scan_data.plugins.platform.plugins.each do |plugin|
      cvss = plugin.attributs.cvss_cvss_v3_base_score
      vulns_per_severity[SeverityMapper.cvss_to_severity(cvss.to_i).to_sym] << plugin.id
    end
    assert_equal 48, vulns_per_severity[:critical].count
    assert_equal 102, vulns_per_severity[:high].count
    assert_equal 112, vulns_per_severity[:medium].count
    assert_equal 26, vulns_per_severity[:low].count
    assert_equal 63, vulns_per_severity[:trivial].count
    assert_equal 351, vulns_per_severity.values.sum(&:count)
    # Find plugin related to vulnerability
    plugin = scan_data.plugins.platform.plugins.find do |plug|
      plug.id == '1078758'
    end
    all_linked_vulns = []
    scan_data.platform.hosts.each do |host|
      linked_vulns = host.vulnerabilities.select do |ws_vuln|
        ws_vuln.id == plugin.id
      end
      all_linked_vulns += linked_vulns
    end
    assert_equal 46, all_linked_vulns.count
    # List all exploit sources
    exploit_src_list = []
    scan_data.plugins.platform.plugins.each do |plugi|
      next if plugi.exploitable == 'False'

      plugi.exploits.each do |exploit_id|
        # Find corresponding xref
        ws_xref = plugi.xrefs.find { |xref| xref.description == exploit_id }
        exploit_src_list << [ws_xref.description, ws_xref.url]
      end
    end
    assert_equal 164, exploit_src_list.count
  end
end
