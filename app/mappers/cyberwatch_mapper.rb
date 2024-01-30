# frozen_string_literal: true

class CyberwatchMapper
  DEFAULT_TIME = Date.new(1969, 9, 2) # Création d'internet
  LEVEL_TO_SEVERITY = {
    level_critical: 'critical',
    level_high: 'high',
    level_medium: 'medium',
    level_low: 'low',
    level_none: 'trivial',
    level_unknown: 'trivial' # Ajouter un level | Garder trivial jusqu'à la MAJ ?
  }.freeze
  EXPLOIT_MATURITY_TO_KIND = {
    high: 'vulnerability',
    functional: 'potential_vulnerability',
    proof_of_concept: 'vulnerability_or_potential_vulnerability',
    unproven: 'information_gathered',
    undefined: 'information_gathered' # Ajouter un kind | Garder IG jusqu'à la MAJ ?
  }.freeze

  class << self
    # @param **json_asset:** Returned json asset
    # @param **account_id:** CyberwatchConfig id
    # @return a hash built with provided data
    def asset_h(json_asset, account_id)
      name = json_asset['hostname'] || "CBW-#{json_asset['id']}"
      env = json_asset['environment']
      os = json_asset['os']
      os_name = os.present? ? "#{os['name']} #{os['arch']}" : nil
      {
        name: name,
        description: json_asset['description'],
        category: json_asset['category'],
        os: os_name,
        confidentiality: env['confidentiality_requirement'],
        integrity: env['integrity_requirement'],
        availability: env['availability_requirement'],
        account_id: account_id
      }
    end

    # @param **created_asset:** Created asset
    # @return a hash built with provided data
    def target_h(created_asset)
      {
        name: "#{created_asset.name} target",
        assets: [created_asset],
        kind: 'VmTarget'
      }
    end

    def vulnerability_h(vuln, vulnerability_import)
      cve_code = vuln['cve_code']
      cvss_h = parse_cvss(vuln)
      {
        import_id: vulnerability_import.id,
        qid: cve_code,
        kb_type: :cyberwatch,
        cve_id: [cve_code],
        category: vuln['cwe'].nil? ? 'Unknown' : vuln['cwe']['cwe_id'],
        title: vuln['content'].nil? ? cve_code : "#{vuln['content'][0, 100]}...",
        modified: vuln['last_modified'] || DEFAULT_TIME,
        published: vuln['published'] || DEFAULT_TIME,
        diagnosis: vuln['content'],
        kind: exploit_maturity_to_kind(vuln['exploit_code_maturity']),
        severity: level_to_severity(vuln['level'], cvss_h),
        exploitability_score: vuln['exploitable'] == 'true' ? 1 : 0,
        patchable: 0,
        pci_flag: 0,
        remote: 0
      }.merge(cvss_h)
    end

    def vulnerability_details_h(details)
      description = details['content'] || ''
      technologies = vuln_details_technologies(details)
      announcements = vuln_details_announcements(details)
      { diagnosis: description + technologies + announcements }
    end

    def vm_scan_h(existing_asset, scan_import, launched_at)
      scan_name = "#{existing_asset.name} #{Date.parse(launched_at).strftime('%d/%m/%y')}"
      {
        targets: existing_asset.targets,
        reference: "CBW scan: #{scan_name}",
        name: scan_name,
        scan_type: 'CyberWatch',
        status: 'Finished',
        duration: 0, # ???
        launched_at: launched_at,
        account_id: scan_import.account.id,
        import_id: scan_import.id
      }
    end

    def vm_occurrence_h(vuln_id, scan_id, vuln, fqdn)
      {
        vulnerability_id: vuln_id,
        scan_id: scan_id,
        result: vuln['comment'], # ???
        fqdn: fqdn
      }
    end

    def vuln_details_technologies(vuln_details)
      technologies = ''
      if vuln_details['technologies'].present?
        technologies = '<br/><br/><b>Affected technologies:</b>'
        vuln_details['technologies'].each do |techno|
          technologies = "#{technologies}<br/>- " \
                         "#{techno['vendor'].capitalize} #{techno['product']}"
        end
      end
      technologies
    end

    def vuln_details_announcements(vuln_details)
      announcements = ''
      if vuln_details['security_announcements'].present?
        announcements = '<br/><br/><b>Security announcements:</b>'
        vuln_details['security_announcements'].each do |announcement|
          corp = announcement['type'].reverse.chomp('SecurityAnnouncements::'.reverse).reverse
          announcements = "#{announcements}<br/><a href='#{announcement['link']}'>" \
                          "- #{corp} #{announcement['sa_code']}</a>"
        end
      end
      announcements
    end

    def exploit_maturity_to_kind(level)
      EXPLOIT_MATURITY_TO_KIND[level.to_sym]
    end

    def level_to_severity(level, cvss_h)
      # if cyberwatch doesnt give a security level, find one from cvss score
      if level == 'level_unknown' && !cvss_h['cvss'].nil?
        SeverityMapper.cvss_to_severity(cvss_h['cvss'])
      else
        LEVEL_TO_SEVERITY[level.to_sym]
      end
    end

    def parse_cvss(vulnerability)
      result = {}
      result['cvss'] =
        vulnerability['score_v3'] || vulnerability['score_v2'] || vulnerability['score']
      result['cvss_version'] = if vulnerability['score_v3'].present?
                                 '3'
                               elsif vulnerability['score_v2'].present?
                                 '2'
                               elsif vulnerability['score'].present?
                                 '1'
                               end
      result['cvss_vector'] = if result['cvss_version'] == '3'
                                vulnerability['cvss_v3'].to_s
                              else
                                vulnerability['cvss'].to_s
                              end
      result
    end
  end
end
