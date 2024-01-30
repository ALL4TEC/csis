# frozen_string_literal: true

class Importers::Cyberwatch::VulnerabilitiesImporterService
  PER_PAGE = 10_000
  API_PATH = 'v3/vulnerabilities/cve_announcements'

  class << self
    # @param **vulnerability_import:** VulnerabilityImport
    # @param **opts:** Cyberwatch api options
    def import_vulnerabilities(vulnerability_import, opts)
      new.handle_import(vulnerability_import, opts)
    end

    # @param **vuln:** already existing Vulnerability
    # @param **account:** CyberwatchConfig
    def import_vulnerability_details(vuln, account)
      new.handle_import_details(vuln, account)
    end
  end

  def handle_import(vulnerability_import, _opts)
    vulnerability_import.update(status: :processing)
    page = 0
    loop do
      vulnerabilities = ::Cyberwatch::Request.do_list(
        vulnerability_import.account,
        API_PATH,
        per_page: PER_PAGE,
        page: page
      )
      break if vulnerabilities.empty?

      page += 1
      handle_vulnerabilities(vulnerabilities, vulnerability_import) # vulnerability_import
    end

    Rails.logger.debug { "#{self.class} : OK" }
    vulnerability_import.update(status: :completed)
  end

  def handle_import_details(vuln, account)
    return if vuln.nil?

    details = ::Cyberwatch::Request.do_singular(
      account,
      "#{API_PATH}/#{vuln.qid}"
    )

    handle_vulnerability_details(vuln, details)
  end

  private

  def handle_vulnerabilities(vulnerabilities, vulnerability_import)
    vulnerabilities.each { |vuln| handle_vulnerability(vuln, vulnerability_import) }
  end

  def handle_vulnerability(vuln, vulnerability_import)
    cve_code = vuln['cve_code']
    return if Vulnerability.find_by(qid: cve_code, kb_type: :cyberwatch)

    Vulnerability.create!(CyberwatchMapper.vulnerability_h(vuln, vulnerability_import))
  end

  def handle_vulnerability_details(vuln, details)
    vuln.update(CyberwatchMapper.vulnerability_details_h(details))
  end
end
