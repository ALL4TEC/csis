# frozen_string_literal: true

module Importers
  class Scb::ZaproxyImporterService < ScanImporterService
    # rubocop:disable Lint/InterpolationCheck
    # rubocop:disable Layout/LineLength
    MAPPINGS = {
      content_type: 'json',
      WaScan: {
        # internal_id:,
        name: '"ZAP: #{report_scan_import.scan_import.scan_launch.target}"',
        reference: '"zaproxy scan: #{SecureRandom.hex(10)}"',
        scan_type: '"#{report_scan_import.scan_import.scan_launch.scan_type}"',
        mode: '"MANUAL"',
        multi: '"false"',
        scanner_appliance_type: '"EXTERNAL"',
        # cancel_option: scan.cancel_option,
        # profile_id: scan.profile_id,
        # profile_name: scan.profile_name,
        launched_at: '"#{report_scan_import.scan_import.scan_launch.launched_at}"',
        launched_by: '"#{report_scan_import.scan_import.scan_launch.launcher.full_name}"',
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
        name: '"#{report_scan_import.scan_import.scan_launch.target}"',
        url: '"#{report_scan_import.scan_import.scan_launch.target}"'
      },
      WaOccurrence: {
        struct: 'finding_attributes.zap_finding_urls',
        uri: '"#{zap_finding_url.uri}"',
        content: '"#{zap_finding_url.evidence}"',
        param: '"#{zap_finding_url.param}"',
        payload: '"#{finding.finding_attributes.zap_otherinfo}"',
        data: '"HTTP Verb: #{zap_finding_url.zap_finding_url_method} | Browser: #{zap_finding_url.attack}"'
        # result: nil
      },
      Vulnerability: {
        struct: 'findings',
        qid: '"ZAP-#{finding.finding_attributes.zap_pluginid}-#{finding.finding_name}"',
        kb_type: '"zaproxy"',
        title: '"#{finding.finding_name}"',
        modified: '"#{TODAY}"',
        published: '"#{TODAY}"',
        category: '"CWE-#{finding.finding_attributes.zap_cweid}, \
                   WASC-#{finding.finding_attributes.zap_wascid}"',
        severity: '"#{severity}"',
        diagnosis: '"#{finding.description}"',
        solution: '"#{finding.finding_attributes.zap_solution}"',
        kind: '"#{kind}"',
        internal_type: '"#{kind.to_s.camelize}"',
        patchable: '"0".to_i',
        pci_flag: '"0".to_i',
        remote: '"0".to_i'
      }
    }.freeze
    # rubocop:enable Layout/LineLength
    # rubocop:enable Lint/InterpolationCheck

    def initialize(job)
      super(SecureCodeBox::Zaproxy, :Wa, MAPPINGS, job)
    end

    def map_kind(finding)
      attributes = finding.finding_attributes
      riskcode = attributes.zap_riskcode.to_i
      confidence = attributes.zap_confidence.to_i
      ZaproxyMapper.map_kind(riskcode, confidence)
    end

    def map_severity(finding)
      ZaproxyMapper.map_severity(finding.finding_attributes.zap_riskcode.to_i)
    end
  end
end
