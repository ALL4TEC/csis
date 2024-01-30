# frozen_string_literal: true

class Qualys::ScanResult
  attr_reader :results

  def initialize(data)
    @results = []
    data.each do |res|
      @results << Qualys::ScanTest.new(res)
    end
  end

  def self.fetch(account, scan_ref)
    Qualys::Request.do_singular(
      account,
      self,
      nil,
      'scan/',
      action: 'fetch',
      scan_ref: scan_ref,
      output_format: 'json',
      mode: 'extended'
    )
  end
end
