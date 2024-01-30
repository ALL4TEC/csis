# frozen_string_literal: true

module Importers::Qualys::JobTestHelper
  SCAN = '//SCAN'
  WAS_SCAN = '//WasScan'
  WAS_SCAN_ = './/WasScan'
  SERVICE_RESPONSE = '//ServiceResponse'

  def stub_it
    proc do |_a0, _a1, a2|
      file = if a2 == SCAN
               'Qualys_Scan'
             elsif a2 == WAS_SCAN_
               'QualysWa_Scan'
             elsif a2 == WAS_SCAN
               'QualysWa_ScanResult'
             elsif a2 == SERVICE_RESPONSE
               'QualysWa_Webapp'
             else
               'Qualys_ScanResult'
             end

      YAML.safe_load_file(
        "test/fixtures/files/JobTestValues/#{file}.txt",
        permitted_classes: [
          ::Qualys::ListResponse,
          ::Qualys::Scan,
          ::ActiveSupport::TimeWithZone,
          Time,
          ::ActiveSupport::TimeZone,
          ::QualysWa::ListResponse,
          ::QualysWa::Scan,
          ::QualysWa::WebApp,
          ::QualysWa::Webapp,
          ::QualysWa::ScanResult,
          ::QualysWa::ScanTest,
          ::Qualys::ScanResult,
          ::Qualys::ScanTest
        ],
        permitted_symbols: [],
        aliases: true
      ) # Authorize aliases
    end
  end

  def launch_test_with_stub
    stub = stub_it
    ::Qualys::Request.stub(:do_list, stub) do
      ::QualysWa::Request.stub(:do_list, stub) do
        ::Qualys::Request.stub(:do_singular, stub) do
          ::QualysWa::Request.stub(:do_singular, stub) do
            assert_stub

            # YAML et Nokogiri::XML::Element ne s'entendent pas bien...
            ::QualysWa::WebApp.stub_any_instance(:url, 'www.google.com') do
              assert_equal ::QualysWa::WebApp.new(Nokogiri::XML::Document.new).url.class,
                String
              yield('cmd')
            end

            yield('asserts')
          end
        end
      end
    end
  end

  def assert_stub
    assert_equal ::Qualys::Request.do_list(nil, nil, SCAN).class, ::Qualys::ListResponse
    assert_equal ::QualysWa::Request.do_list(nil, nil, WAS_SCAN_).class, ::QualysWa::ListResponse
    assert_equal ::Qualys::Request.do_singular(nil, nil, nil).class, ::Qualys::ScanResult
    assert_equal ::QualysWa::Request.do_singular(nil, nil, WAS_SCAN).class, ::QualysWa::ScanResult
    assert_equal(
      ::QualysWa::Request.do_singular(nil, nil, SERVICE_RESPONSE).class, ::QualysWa::Webapp
    )
  end
end
