# frozen_string_literal: true

class QualysMapper
  UPDATE_WAS = 'Update Was'

  class << self
    # @param **scan:** Qualys::Scan
    # @param **scan_import:** ScanImport
    # @param **vmclient:** QualysVmClient
    # @return a hash built with provided data
    def vm_scan_h(scan, scan_import, vmclient)
      {
        import_id: scan_import.id,
        account: scan_import.account,
        qualys_vm_client: vmclient,
        reference: scan.reference,
        scan_type: scan.type,
        name: scan.title,
        launched_by: scan.user_login,
        launched_at: scan.launched,
        duration: scan.duration,
        processed: scan.processed,
        status: scan.state,
        target: scan.target,
        option_title: scan.option_title,
        option_flag: scan.option_flag
      }
    end

    # @param **vuln:** Persisted CSIS vulnerability
    # @param **qualys_scan_result:** Qualys::ScanResult
    # @param **current_scan:** Scan to link to
    # @return a hash built with provided data
    def vm_occurrence_h(vuln, qualys_scan_result, current_scan)
      {
        vulnerability_id: vuln.id,
        netbios: qualys_scan_result.netbios,
        result: qualys_scan_result.result,
        fqdn: qualys_scan_result.fqdn,
        ip: qualys_scan_result.ip,
        scan: current_scan
      }
    end

    def wa_scan_h(scan, scan_import, waclient)
      {
        import_id: scan_import.id,
        account: scan_import.account,
        qualys_wa_client: waclient,
        internal_id: scan.id,
        name: scan.name,
        reference: scan.reference,
        scan_type: scan.type,
        mode: scan.mode,
        multi: scan.multi,
        scanner_appliance_type: scan.scanner_appliance_type,
        cancel_option: scan.cancel_option,
        profile_id: scan.profile_id,
        profile_name: scan.profile_name,
        launched_at: scan.launched,
        launched_by: scan.launched_by_username,
        status: scan.status,
        crawl_duration: scan.crawl_duration,
        test_duration: scan.test_duration,
        links_crawled: scan.links_crawled,
        nb_requests: scan.nb_requests,
        results_status: scan.results_status,
        auth_status: scan.auth_status,
        os: scan.os
      }
    end

    def wa_target_h(scan)
      {
        reference_id: scan.web_apps.first.id,
        name: scan.web_apps.first.name,
        url: scan.web_apps.first.url,
        kind: 'WaTarget'
      }
    end

    # @return WaOccurrence h built with provided data
    def wa_occurrence_h(vuln, scan, qualys_scan_result, occurrence = nil)
      occ_h = {
        vulnerability_id: vuln.id,
        scan: scan,
        uri: qualys_scan_result.uri,
        content: qualys_scan_result.content,
        param: qualys_scan_result.param,
        payload: qualys_scan_result.payload,
        data: qualys_scan_result.data,
        result: qualys_scan_result.result
      }
      if occurrence.present?
        occ_h[:uri] = "#{occ_h[:uri]}#{UPDATE_WAS}#{occurrence.uri}"
        occ_h[:content] = "#{occ_h[:content]}<br>#{UPDATE_WAS}<br>#{occurrence.content}"
        occ_h[:param] = "#{occ_h[:param]}#{UPDATE_WAS}#{occurrence.param}"
        occ_h[:payload] = "#{occ_h[:payload]}#{UPDATE_WAS}#{occurrence.payload}"
        occ_h[:data] = "#{occ_h[:data]}#{UPDATE_WAS}#{occurrence.data}"
        occ_h[:result] = "#{occ_h[:result]}<br>#{UPDATE_WAS}<br>#{occurrence.result}"
      end
      occ_h
    end

    def vulnerability_h(qualys_vuln, exploits, vulnerability_import)
      {
        import_id: vulnerability_import.id,
        kb_type: :qualys,
        # Must titleize: Capitalize all words of string, then remove whitespaces before underscore
        kind: qualys_vuln.vuln_type.titleize.delete(' ').underscore,
        severity: qualys_vuln.severity.to_i - 1,
        internal_type: qualys_vuln.vuln_type,
        title: qualys_vuln.title,
        category: qualys_vuln.category,
        patchable: qualys_vuln.patchable,
        diagnosis: qualys_vuln.diagnosis,
        consequence: qualys_vuln.consequence,
        solution: qualys_vuln.solution,
        pci_flag: qualys_vuln.pci_flag,
        modified: qualys_vuln.modified,
        published: qualys_vuln.published,
        remote: qualys_vuln.remote,
        additional_info: qualys_vuln.additional_info,
        bugtraqs: qualys_vuln.bugtraqs,
        cve_id: qualys_vuln.cve_id,
        exploits: exploits
      }
    end
  end
end
