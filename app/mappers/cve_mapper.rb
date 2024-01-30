# frozen_string_literal: true

class CveMapper
  class << self
    def cve_to_h(cve, vulnerability_import)
      kind = :vulnerability
      {
        import_id: vulnerability_import.id,
        kb_type: :cve,
        qid: cve.title,
        title: cve.title,
        published: cve.published,
        modified: cve.modified,
        category: cve.category,
        severity: SeverityMapper.cvss_to_severity(cve.cvss),
        cvss: cve.cvss,
        cvss_version: cve.cvss_version,
        cvss_vector: cve.cvss_vector,
        cve_id: [],
        bugtraqs: cve.bugtraqs,
        osvdb: cve.osvdb,
        diagnosis: cve.description,
        solution: 'Read description',
        kind: kind,
        internal_type: kind.to_s.camelize,
        patchable: 0,
        pci_flag: 0,
        remote: 0
      }
    end
  end
end
