# frozen_string_literal: true

class QualysWa::ScanResult
  attr_reader :results

  def initialize(data)
    @results = []
    return if data.nil?

    data.xpath('.//WasScanIg')&.each do |res|
      @results << QualysWa::ScanTest.new(res)
    end
    data.xpath('.//WasScanVuln')&.each do |res|
      @results << QualysWa::ScanTest.new(res)
    end
    data.xpath('.//WasScanSensitiveContent')&.each do |res|
      @results << QualysWa::ScanTest.new(res)
    end
  end

  # Get Qualys Wa scan infos
  def self.fetch(account, scan_ref)
    api = { path: "download/was/wasscan/#{scan_ref}", method: 'GET' }
    QualysWa::Request.do_singular(account, self, '//WasScan', api)
  end
end
