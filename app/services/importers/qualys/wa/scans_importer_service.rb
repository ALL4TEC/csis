# frozen_string_literal: true

class Importers::Qualys::Wa::ScansImporterService
  TAGS_KEY = :'webApp.tags.id'

  class << self
    # Import multiple Qualys VmScans
    # @param **scan_import:** ScanImport
    # @param **opts:** Qualys API call options
    def import_wa_scans(scan_import, opts)
      scan_import.update(status: :processing)
      new.handle_import(scan_import, opts)
      scan_import.update(status: :completed)
    end

    # Update multiple Qualys VmScans
    # @param **scan_import:** ScanImport
    # @param **reference:** Scan reference, default to nil
    # @param **opts:** Qualys API call options
    def update_wa_scans(scan_import, reference = nil, opts = {},
      only_thumbnail: false, force_thumbnail: false)
      scan_import.update(status: :processing)
      new.handle_update(scan_import, reference, opts, only_thumbnail, force_thumbnail)
      scan_import.update(status: :completed)
    end
  end

  # Handle multiple scans update
  # @param scan_import: ScanImport
  # @param reference = WaScan.internal_id
  def handle_update(scan_import, reference, options, only_thumbnail, force_thumbnail)
    account = scan_import.account
    if reference.present?
      update_wa_scan(scan_import,
        QualysWa::Scan.get(account, reference),
        only_thumbnail,
        force_thumbnail)
    else
      options = handle_opts(account, options)
      scans = QualysWa::Scan.list(account, options)
      Rails.logger.debug { "Found #{scans.data.length} Wa Scans" }
      scans.data.each do |scan|
        update_wa_scan(scan_import, scan, only_thumbnail, force_thumbnail)
      end
    end
  end

  # Handle Qualys WA scans import
  # @param **scan_import:** ScanImport
  # @param **opts:** Qualys API options
  def handle_import(scan_import, opts)
    account = scan_import.account
    opts = handle_opts(account, opts)
    scans = QualysWa::Scan.list(account, opts)
    Rails.logger.debug { "Found #{scans.data.length} Wa Scans" }
    scans.data.each do |scan|
      import_wa_scan(scan_import, scan)
    end
  end

  private

  # Update one WaScan from QualysWa::Scan
  # @param scan_import: ScanImport
  # @param scan: QualysWa::Scan
  def update_wa_scan(scan_import, scan, only_thumbnail, force_thumbnail)
    account = scan_import.account
    # WaScan.reference is qualys textual reference
    updatescan = WaScan.find_by(reference: scan.reference)
    return if updatescan.nil?

    webapp = QualysWa::Webapp.get(account, scan.web_apps.first.id)
    return unless webapp.is_a?(QualysWa::Webapp)

    waclient = QualysWaClient.find_by(qualys_id: webapp.tag_id, qualys_config_id: account.id)
    update_scan(updatescan, scan, scan_import, waclient) unless only_thumbnail
    handle_landing_page_update(updatescan, scan, webapp, force_thumbnail)
    handle_occurrences_update(account, updatescan, scan) unless only_thumbnail
  end

  # Import one QualysWa::Scan
  # Creates WaScan
  # @param **scan_import:** ScanImport
  # @param **scan:** QualysWa::Scan to import
  def import_wa_scan(scan_import, scan)
    account = scan_import.account
    webapp = QualysWa::Webapp.get(account, scan.web_apps.first.id)
    Rails.logger.debug { "webapp.class:#{webapp.class}" }
    return unless webapp.is_a?(QualysWa::Webapp)

    waclient = QualysWaClient.find_by(qualys_id: webapp.tag_id, qualys_config_id: account.id)
    Rails.logger.debug { "webapp tag:#{webapp.tag_id}|waclient:#{waclient}" }
    return unless WaScan.find_by(reference: scan.reference).nil?

    current_scan = create_wa_scan(scan, scan_import, waclient)
    handle_landing_page(current_scan, scan, webapp)
    handle_occurrences_creation(account, current_scan, scan)
  end

  # Create WaScan with QualysWa::Scan infos
  # @param scan: QualysWa::Scan
  # @param scan_import: ScanImport
  # @param waclient: QualysWaClient if found from webapp tag
  def create_wa_scan(scan, scan_import, waclient)
    created_wa_scan = WaScan.create!(QualysMapper.wa_scan_h(scan, scan_import, waclient))
    Rails.logger.debug { "Qualys WA Scan Creation #{scan.reference}: OK" }
    handle_wa_target(created_wa_scan, scan)
    created_wa_scan
  end

  # Update WaScan with QualysWa::Scan infos
  # @param updatescan: WaScan
  # @param scan: QualysWa::Scan
  # @param scan_import: ScanImport
  # @param waclient: WaClient found from webapp tag_id
  def update_scan(updatescan, scan, scan_import, waclient)
    updatescan.update!(QualysMapper.wa_scan_h(scan, scan_import, waclient))
    Rails.logger.debug { "Qualys WA Scan Update #{scan.reference}: OK" }
  end

  def handle_wa_target(current_scan, qualys_scan_result)
    target = Target.find_or_create_by!(QualysMapper.wa_target_h(qualys_scan_result))
    current_scan.targets << target unless target.id.in?(current_scan.target_ids)
  end

  # Update wa occurrences
  def update_occurrences(occurrences, res, updatescan, vuln)
    occurrences.each do |occ|
      occ.update!(QualysMapper.wa_occurrence_h(vuln, updatescan, res, occ))
    end
  end

  # Create wa occurrence
  def create_occurrence(current_scan, vuln, res)
    occ = WaOccurrence.create!(QualysMapper.wa_occurrence_h(vuln, current_scan, res))
    Rails.logger.debug { "Qualys Wa Occurrence Creation #{occ.id}: OK" }
  end

  def handle_occurrences(account, scan)
    QualysWa::ScanResult.fetch(account, scan.id).results.each do |res|
      vuln = Vulnerability.find_by(qid: res.qid)
      next if vuln.nil?

      yield vuln, res
    end
  end

  def handle_occurrences_creation(account, current_scan, scan)
    handle_occurrences(account, scan) do |vuln, res|
      create_occurrence(current_scan, vuln, res)
      Rails.logger.debug { "Qualys WA Scan Import occurrences of #{scan.reference}: OK" }
    end
  end

  # Update WaOccurrences linked to updated scans
  # @param account: QualysAccount
  # @param updatescan: WaScan being updated
  # @param scan: QualysWa::Scan used to update
  def handle_occurrences_update(account, updatescan, scan)
    handle_occurrences(account, scan) do |vuln, res|
      occurrences = WaOccurrence.where(scan_id: updatescan.id, vulnerability_id: vuln.id)
      next if occurrences.empty?

      update_occurrences(occurrences, res, updatescan, vuln)
      Rails.logger.debug { "Qualys WA Scan Update occurrences of #{scan.reference}: OK" }
    end
  end

  # Handle landing_page infos
  # @param **csis_scan:** WaScan being updated
  # @param **scan:** Qualys::Scan used to update
  # @param **webapp:** Qualys Webapp
  def handle_landing_page(csis_scan, scan, webapp)
    attachfilename = "wascan_##{csis_scan.internal_id}_lp##{webapp.id}"

    tmp = Tempfile.new([attachfilename, '.jpg'])
    File.open(tmp.path, 'w+b') do |f|
      f.write(Base64.decode64(webapp.screenshot))
      f.rewind
      blob = ActiveStorage::Blob.create_and_upload!(
        io: f,
        filename: "#{attachfilename}.jpg",
        content_type: 'image/jpeg',
        identify: false
      )
      csis_scan.update!(landing_page: blob)
    end
    tmp.unlink
    Rails.logger.debug { "Qualys WA Scans Update : #{scan.reference}, screenshot: OK!" }
  rescue StandardError => e
    Rails.logger.warn "Error while handling landing page: #{e}"
  end

  # Handle landing_page infos
  # @param **csis_scan:** WaScan being updated
  # @param **scan:** Qualys::Scan used to update
  # @param **webapp:** Qualys Webapp
  # @param **force_thumbnail:** Only used in update mode
  def handle_landing_page_update(csis_scan, scan, webapp, force_thumbnail = nil)
    if !force_thumbnail && csis_scan.landing_page.attached?
      Rails.logger.debug do
        "Qualys WA Scans Update : #{scan.reference}, screenshot already present"
      end
    else
      handle_landing_page(csis_scan, scan, webapp)
    end
  end

  # Handle Qualys WA API call options
  # @param **account:** QualysConfig
  # @param **opts:** Qualys API call options
  def handle_opts(account, opts)
    # Si :consultants on envoie les clients ids en filtre si au moins un
    if account.ext.consultants_kind?
      if opts.key?(TAGS_KEY)
        # On supprime le filtre s'il est vide
        opts.delete(TAGS_KEY) if opts[TAGS_KEY].empty?
      else
        # On va chercher uniquement les clients ids si existants pour les set par défaut
        tags = account.qualys_wa_clients.flat_map(&:qualys_id).join(',')
        opts[TAGS_KEY] = tags if tags.present?
      end
    end
    opts
  end
end
