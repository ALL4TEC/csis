# frozen_string_literal: true

module Importers
  class NessusImporterService < ScanImporterService
    # rubocop:disable Lint/InterpolationCheck
    MAPPINGS = {
      content_type: 'xml',
      VmScan: {
        struct: 'report_host',
        name: '"NESSUS: #{report_host.name}"',
        launched_at: '"#{Time.zone.at(report_host.host_start_timestamp.to_i)}"',
        duration: '"#{Time.zone.at(report_host.host_end_timestamp.to_i - \
                      report_host.host_start_timestamp.to_i).utc.strftime(\'%H:%M:%S\')}"',
        # account: account,
        # qualys_vm_client: vmclient,
        reference: '"nessus scan: #{SecureRandom.hex(10)}"',
        scan_type: '"NESSUS"',
        # user_login: nil,
        # processed: nil,
        status: '"FINISHED"',
        target: '"#{report_host.host_ip}"' # host-ip
        # option_title: nil,
        # option_flag: nil
      },
      VmOccurrence: {
        netbios: '"#{report_host.host_netbios}"',
        result: '"#{report_item.plugin_output}"',
        fqdn: '"#{report_host.host_fqdn}"',
        ip: '"#{report_host.host_ip}"'
      },
      Vulnerability: {
        struct: 'report_items',
        qid: '"NESSUS-#{report_item.plugin_id}"',
        kb_type: '"nessus"',
        title: '"#{report_item.plugin_name}"',
        published: '"#{report_item.plugin_publication_date}"',
        modified: '"#{report_item.plugin_modification_date}"',
        category: '"#{report_item.plugin_family}"',
        severity: '"#{severity}"',
        bugtraqs: '"#{report_item.bid}".split', # Maybe exploits
        diagnosis: '"#{report_item.description}"',
        solution: '"#{report_item.solution}"',
        kind: '"#{kind}"',
        internal_type: '"#{kind.to_s.camelize}"',
        patchable: '"#{report_item.patch_publication_date.present? ? 1 : 0}"',
        pci_flag: '"0".to_i',
        remote: '"#{report_item.plugin_type == \'remote\' ? 1 : 0}"',
        cve_id: '"#{report_item.cve}".split',
        consequence: '"#{report_item.synopsis}"',
        additional_info: '"#{report_item.fname} - #{report_item.script_version}"',
        cvss: '"#{report_item.cvss_base_score}"',
        cvss_vector: '"#{report_item.cvss_vector}"',
        cvss_version: '"2".to_i'
      }
    }.freeze
    # rubocop:enable Lint/InterpolationCheck

    def initialize(job)
      super(Nessus, :Vm, MAPPINGS, job)
    end

    private

    # method to override per scanner
    def map_kind(report_item)
      NessusMapper.map_kind(report_item)
    end

    # method to override per scanner
    def map_severity(report_item)
      NessusMapper.map_severity(report_item)
    end
  end
end
