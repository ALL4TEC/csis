# frozen_string_literal: true

module Importers::Cyberwatch::JobTestHelper
  ASSETS = 'v3/assets/servers'
  SCANS = 'v3/vulnerabilities/servers'
  VULNS = 'v3/vulnerabilities/cve_announcements'

  def stub_it
    proc do |_a0, a1, a2|
      file = if a1 == ASSETS
               'Cyberwatch_Assets'
             elsif a1 == SCANS
               'Cyberwatch_Vulnerable_Assets'
             elsif a1 == VULNS
               'Cyberwatch_Vulnerabilities'
             else
               'Cyberwatch_Scans'
             end

      if a2 && a2[:page] && a2[:page].positive?
        {}
      else
        JSON.parse(File.read("test/fixtures/files/JobTestValues/#{file}.json"))
      end
    end
  end

  def launch_test_with_stub
    stub = stub_it
    ::Cyberwatch::Request.stub(:do_list, stub) do
      ::Cyberwatch::Request.stub(:do_singular, stub) do
        assert_stub
        yield('cmd')
        yield('asserts')
      end
    end
  end

  def assert_stub
    assert_equal ::Cyberwatch::Request.do_list(nil, SCANS, nil).class, Array
    assert_equal ::Cyberwatch::Request.do_list(nil, ASSETS, nil).class, Array
    assert_equal ::Cyberwatch::Request.do_list(nil, VULNS, nil).class, Array
    assert_equal ::Cyberwatch::Request.do_singular(nil, nil, nil).class, Hash
  end
end
