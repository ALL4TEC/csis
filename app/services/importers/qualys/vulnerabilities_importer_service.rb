# frozen_string_literal: true

class Importers::Qualys::VulnerabilitiesImporterService
  SIZE = 50_000

  # @param **vulnerability_import:** VulnerabilityImport
  # @param **last_modified:** Array of last modified Qualys vulnerabilities
  def self.import_vulnerabilities(vulnerability_import, last)
    new.handle_import(vulnerability_import, last)
  end

  def handle_import(vulnerability_import, last)
    vulnerability_import.update(status: :processing)
    last_modified = handle_last(last)
    Rails.logger.debug { "#{self.class}: Launching (last_modified: #{last_modified})" }
    if last_modified.present?
      import_since_last_modified(vulnerability_import, last_modified)
    else
      import_all(vulnerability_import)
    end
    vulnerability_import.update(status: :completed)
  end

  private

  # Handle last parameter
  # @param **last:** Boolean to indicate if we must import only vulnerabilities since last modified
  # @return **last_modified vulnerability 'modified' value**
  def handle_last(last)
    return nil unless last

    last_modified_vuln = Vulnerability.order('modified').first
    return nil if last_modified_vuln.blank?

    last_modified_vuln.modified
  end

  # Import only vulnerabilities since last_modified date
  # @param **vulnerability_import:** VulnerabilityImport
  # @param **last_modified:** Last persisted vulnerability 'modified' value
  def import_since_last_modified(vulnerability_import, last_modified)
    account = vulnerability_import.account
    vulnerabilities = Qualys::Vulnerability.list_modified_since(account,
      last_modified.to_s[0, 10])
    handle_vulnerabilities(vulnerabilities, vulnerability_import)
  end

  # Import all vulnerabilities
  # @param **vulnerability_import:** VulnerabilityImport
  def import_all(vulnerability_import)
    account = vulnerability_import.account
    page = 0
    loop do
      vulnerabilities = Qualys::Vulnerability.list(account, page * SIZE, (page + 1) * SIZE)
      break unless vulnerabilities.data.any?

      page += 1
      handle_vulnerabilities(vulnerabilities, vulnerability_import)
    end
  end

  # Find or create exploit
  # @param **exploit:** Exploit to find or create
  # @param **exploit_src:** Exploit source
  # @return persisted Exploit
  def handle_exploit(exploit, exploit_src)
    Exploit.find_or_create_by!(reference: exploit.reference, link: exploit.link) do |record|
      record.reference = exploit.reference
      record.description = exploit.description
      record.link = exploit.link
      record.exploit_source = exploit_src
    end
  end

  # Find or create exploits
  # @param **exploits:** Exploits to import
  # @param **exploit_src:** Exploit source
  # @return persisted exploits as list
  def import_exploits(exploits, exploit_src)
    exploit_list = []
    exploits.each do |exploit|
      exploit_list << handle_exploit(exploit, exploit_src)
    end
    exploit_list
  end

  # Find or create exploit source
  # @param **exploit_src:** Exploit source to find or create
  # @return persisted ExploitSource
  def handle_exploit_source(exploit_src)
    ExploitSource.find_or_create_by!(name: exploit_src.name) do |record|
      record.name = exploit_src.name
    end
  end

  # Find or create exploit sources
  # @param **exploit_srcs:** Exploit sources to import
  # @return persisted exploit sources as list
  def import_exploit_sources(exploit_srcs)
    exploit_list = []
    exploit_srcs.each do |exploit_src|
      exploit_list += import_exploits(exploit_src.exploits, handle_exploit_source(exploit_src))
    end
    exploit_list
  end

  # Find or create vulnerability
  # @param **q_vuln:** Qualys vulnerability data to import
  # @return persisted Vulnerability
  def handle_vulnerability(q_vuln, vulnerability_import)
    exploits = import_exploit_sources(q_vuln.exploit_srcs).uniq
    Vulnerability.find_or_create_by(qid: q_vuln.qid).tap do |vuln|
      break unless q_vuln.modified != vuln.modified

      vuln.assign_attributes(QualysMapper.vulnerability_h(q_vuln, exploits, vulnerability_import))
      vuln.save
    end
  end

  # Find or create vulnerabilities
  # @param **vulnerabilities:** Vulnerabilities to import
  def handle_vulnerabilities(vulnerabilities, vulnerability_import)
    vulnerabilities.data.each { |vuln| handle_vulnerability(vuln, vulnerability_import) }
  end
end
