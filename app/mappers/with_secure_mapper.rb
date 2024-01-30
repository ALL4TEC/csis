# frozen_string_literal: true

class WithSecureMapper
  class << self
    def occurrence_h(created_scan, vulnerability, ip)
      {
        vulnerability_id: vulnerability.id,
        scan: created_scan,
        ip: ip
      }
    end

    def scan_h(report_scan_import, ws_scan_report)
      report_info = ws_scan_report.report_info
      start_date_ts = DateTime.parse(report_info.start_date).to_i
      end_date_ts = DateTime.parse(report_info.end_date).to_i
      duration = Time.zone.at(end_date_ts - start_date_ts).utc.strftime('%H:%M:%S')
      {
        name: "WithSecure: #{ws_scan_report.title}",
        status: 'FINISHED',
        scan_type: :with_secure,
        reference: "WithSecure scan: #{SecureRandom.hex(10)}",
        launched_at: report_info.start_date,
        launched_by: report_info.created_by,
        created_at: report_info.created_on_date,
        duration: duration,
        import_id: report_scan_import.import_id
      }
    end

    def vulnerability_h(ws_vulnerability, ws_plugin, exploits)
      today = Time.zone.now
      severity = SeverityMapper.cvss_to_severity(ws_plugin.attributs.cvss_cvss_v3_base_score.to_i)
      kind = map_kind(severity, ws_vulnerability)
      additional_info = "#{ws_vulnerability.additional_info}\
        |Script_version:#{ws_plugin.script_version}\
        |protocol:#{ws_vulnerability.protocol}\
        |port:#{ws_vulnerability.port}"
      {
        qid: "WithSecure-#{ws_plugin.id}",
        kb_type: 'with_secure',
        title: ws_vulnerability.name,
        published: today,
        modified: today,
        category: ws_plugin.family,
        severity: severity,
        bugtraqs: ws_plugin.bugtraq_ids.join(', '),
        diagnosis: ws_plugin.attributs.description,
        solution: ws_plugin.attributs.solution,
        kind: kind,
        internal_type: kind.to_s.camelize,
        patchable: 0,
        pci_flag: 0,
        remote: 0,
        cve_id: ws_plugin.cve_ids.join(', '),
        consequence: ws_plugin.attributs.synopsis,
        additional_info: additional_info,
        cvss: ws_plugin.attributs.cvss_cvss_v3_base_score,
        cvss_vector: ws_plugin.attributs.cvss_v3_vector,
        cvss_version: 3,
        exploits: exploits
      }
    end

    private

    def map_kind(severity, ws_vulnerability)
      risk_level = ws_vulnerability.risk_level
      risk_factor = ws_vulnerability.risk_factor
      if risk_factor == 'Information'
        :information_gathered
      elsif Vulnerability.severities[severity].zero?
        :vulnerability_or_potential_vulnerability
      elsif risk_level.to_i < 3
        :potential_vulnerability
      else
        :vulnerability
      end
    end
  end
end
