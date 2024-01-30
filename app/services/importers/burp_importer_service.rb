# frozen_string_literal: true

module Importers
  class BurpImporterService < ScanImporterService
    # rubocop:disable Lint/InterpolationCheck
    MAPPINGS = {
      content_type: 'xml',
      WaScan: {
        name: '"BURP: #{_scan.host}"',
        reference: '"burp scan: #{SecureRandom.hex(10)}"',
        scan_type: '"BURP"',
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
        name: '"#{_scan.host}"',
        url: '"#{_scan.host}"'
      },
      WaOccurrence: {
        uri: '"#{issue.host}#{issue.path}"',
        content: '"#{issue.serial_number}"',
        param: '"#{issue.location}"',
        payload: '"#{issue.request_response}"',
        data: '"#{issue.issue_detail}"',
        result: '"#{issue.remediation_detail}"'
      },
      Vulnerability: {
        struct: 'issues',
        qid: '"BURP-#{issue.type}"',
        kb_type: '"burp"',
        title: '"#{issue.name}"',
        modified: '"#{TODAY}"',
        published: '"#{TODAY}"',
        category: '"#{issue.vulnerability_classifications || issue.name}"',
        severity: '"#{severity}"',
        diagnosis: '"#{issue.issue_background}"',
        solution: '"#{issue.remediation_background}"',
        kind: '"#{kind}"',
        internal_type: '"#{kind.to_s.camelize}"',
        patchable: '"0".to_i',
        pci_flag: '"0".to_i',
        remote: '"0".to_i'
      }
    }.freeze
    # rubocop:enable Lint/InterpolationCheck

    def initialize(job)
      super(Burp, :Wa, MAPPINGS, job)
    end

    private

    # method to override per scanner
    def map_kind(issue)
      BurpMapper.map_kind(issue)
    end

    # method to override per scanner
    def map_severity(issue)
      BurpMapper.map_severity(issue)
    end
  end
end
