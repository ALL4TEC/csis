# frozen_string_literal: true

module Importers
  class ZaproxyImporterService < ScanImporterService
    # rubocop:disable Lint/InterpolationCheck
    MAPPINGS = {
      content_type: 'json',
      WaScan: {
        struct: 'site',
        # internal_id:,
        name: '"#{site.site_name}"',
        reference: '"zaproxy scan: #{SecureRandom.hex(10)}"',
        scan_type: '"ZAPROXY"',
        mode: '"MANUAL"',
        multi: '"false"',
        scanner_appliance_type: '"EXTERNAL"',
        # cancel_option: scan.cancel_option,
        # profile_id: scan.profile_id,
        # profile_name: scan.profile_name,
        launched_at: '"#{TODAY}"',
        # launched_by_username: scan.launched_by_username,
        status: '"FINISHED"'
        # crawl_duration: scan.crawl_duration,
        # test_duration: scan.test_duration,
        # links_crawled: scan.links_crawled,
        # nb_requests: scan.nb_requests,
        # results_status: scan.results_status,
        # auth_status: scan.auth_status,
        # os: scan.os
      },
      Target: {
        kind: '"WaTarget"',
        name: '"#{site.site_name}"',
        url: '"#{site.site_name}"'
      },
      WaOccurrence: {
        struct: 'instances',
        uri: '"#{instance.uri}"',
        content: '"#{instance.evidence}"',
        param: '"#{instance.param}"',
        payload: '"#{alert.otherinfo}"',
        data: '"HTTP Verb: #{instance.method1}"'
        # result: nil
      },
      Vulnerability: {
        struct: 'alerts',
        qid: '"ZAP-#{alert.pluginid}-#{alert.riskcode}-#{alert.confidence}"',
        kb_type: '"zaproxy"',
        title: '"#{alert.alert_name}"',
        modified: '"#{TODAY}"',
        published: '"#{TODAY}"',
        category: '"CWE-#{alert.cweid}, WASC-#{alert.wascid}"',
        severity: '"#{severity}"',
        diagnosis: '"#{alert.desc}"',
        solution: '"#{alert.solution}"',
        kind: '"#{kind}"',
        internal_type: '"#{kind.to_s.camelize}"',
        patchable: '"0".to_i',
        pci_flag: '"0".to_i',
        remote: '"0".to_i'
      }
    }.freeze
    # rubocop:enable Lint/InterpolationCheck

    def initialize(job)
      super(Zaproxy, :Wa, MAPPINGS, job)
    end

    # method to override per scanner
    def map_kind(alert)
      riskcode = alert.riskcode.to_i
      confidence = alert.confidence.to_i
      ZaproxyMapper.map_kind(riskcode, confidence)
    end

    # method to override per scanner
    def map_severity(alert)
      ZaproxyMapper.map_severity(alert.riskcode.to_i)
    end
  end
end
