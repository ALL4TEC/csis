# frozen_string_literal: true

class Qualys::ScanTest
  attr_reader :ip,
    :dns,
    :netbios,
    :qid,
    :instance,
    :result,
    :protocol,
    :ssl,
    :fqdn

  def initialize(data)
    @ip = data['ip']
    @dns = data['dns']
    @netbios = data['netbios']
    @qid = data['qid']
    @instance = data['instance']
    @result = data['result']
    @protocol = data['protocol']
    @ssl = data['ssl']
    @fqdn = data['fqdn']
  end
end
