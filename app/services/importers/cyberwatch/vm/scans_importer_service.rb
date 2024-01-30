# frozen_string_literal: true

class Importers::Cyberwatch::Vm::ScansImporterService
  API_PATH = 'v3/vulnerabilities/servers'

  def initialize(scan_import)
    @scan_import = scan_import
    @account = @scan_import.account
  end

  # Passe par toutes les vulns et les range dans des scans en fonction de la
  # date de découverte. Si vuln absente, occurrence non créée ?
  # TODO: Import_last -> Prend la date de MAJ et regarde si le scan correspondant existe, le
  # crée ou ne crée rien.
  # @param **scan_import:** ScanImport
  # @param **opts:** Cyberwatch api options
  def self.import_vm_scans(scan_import, _opts)
    new(scan_import).handle_import
  end

  def handle_import
    @scan_import.update(status: :processing)
    assets = ::Cyberwatch::Request.do_list(@account, API_PATH, {})
    assets.each do |asset|
      handle_asset(asset)
    end
    Rails.logger.debug { "#{self.class} : OK" }
    @scan_import.update(status: :completed)
  end

  private

  # Pour chaque asset, s'il existe en BDD & qu'il a été analysé depuis la dernière sauvegarde
  # on récupère le détail des vulnérabilités associées
  def handle_asset(asset)
    account_id = @account.id
    asset_id = asset['id']
    name = asset['hostname'] || "CBW-#{asset_id}"
    return unless (existing_asset = Asset.find_by(name: name)) &&
                  existing_asset.newly_analyzed?(account_id, asset['analyzed_at'])

    asset_details = ::Cyberwatch::Request.do_singular(@account, "#{API_PATH}/#{asset_id}", {})
    handle_vulns(asset_details, existing_asset)
  end

  def handle_vulns(asset_details, existing_asset)
    vulnerabilities = asset_details['cve_announcements']
    shared_data = {
      last_analyzed_at: existing_asset.analyzed_at(@account.id),
      launched_at: nil,
      scan_id: nil,
      fqdn: asset_details['addresses']&.join(', ')
    }
    vulnerabilities.each do |vuln|
      handle_vuln(vuln, existing_asset, shared_data)
    end
  end

  # Pour chaque vulnerabilité d'existing_asset,
  # Si la vuln a été détectée depuis la dernière analyse
  # On crée un scan que si launched_at est nil, donc au premier passage
  # Et si on a une vuln sans date de détection ???
  # Dans tous les cas on crée une occurence de vuln rattachée au scan
  # précédemment créé et à la vulnérabilité correspondant au code cve (qid)
  # @param **data**: A hash containing shared data between vulns
  # {scan_id: scan_id, launched_at: launched_at}
  def handle_vuln(vuln, existing_asset, shared_data)
    detected_at = vuln['detected_at']
    last_analyzed_at = shared_data[:last_analyzed_at]
    launched_at = shared_data[:launched_at]
    return if last_analyzed_at && (detected_at < last_analyzed_at)

    if launched_at.nil? && (detected_at != launched_at)
      shared_data[:launched_at] = detected_at
      shared_data[:scan_id] = VmScan.create!(
        CyberwatchMapper.vm_scan_h(existing_asset, @scan_import, shared_data[:launched_at])
      ).id
    end

    vuln = Vulnerability.find_by(qid: vuln['cve_code'], kb_type: :cyberwatch)
    vuln_id = vuln&.id
    VmOccurrence.create!(
      CyberwatchMapper.vm_occurrence_h(
        vuln_id, shared_data[:scan_id], vuln, shared_data[:fqdn]
      )
    )
    # update vuln to display impacted technologies and security announcements
    Importers::Cyberwatch::VulnerabilitiesImporterService.import_vulnerability_details(
      vuln, @account
    )
  end
end
