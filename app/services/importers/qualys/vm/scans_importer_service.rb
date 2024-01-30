# frozen_string_literal: true

class Importers::Qualys::Vm::ScansImporterService
  KEYS = %i[scan_ref launched_after_datetime].freeze
  CLIENT_IDS = :client_ids

  def initialize(import_type)
    @import_type = import_type
  end

  # Import multiple Qualys VmScans
  # @param **scan_import:** ScanImport
  # @param **opts:** Qualys API call options
  def self.import_vm_scans(scan_import, opts)
    scan_import.update(status: :processing)
    new(:import).handle_opts(scan_import, opts)
    scan_import.update(status: :completed)
  end

  # Update multiple Qualys VmScans
  # @param **scan_import:** ScanImport
  # @param **reference:** Scan reference, default to nil
  # @param **opts:** Qualys API call options
  def self.update_vm_scans(scan_import, reference = nil, opts = {})
    scan_import.update(status: :processing)
    new(:update).handle_update(scan_import, reference, opts)
    scan_import.update(status: :completed)
  end

  # Simple intermediate method to be called by update_vm_scans
  # If reference  then update scan with reference
  # Else handle options
  # @param **scan_import:** ScanImport
  # @param **reference:** Qualys::Scan reference
  # @param **opts:** Qualys API call options
  def handle_update(scan_import, reference, opts)
    if reference.present?
      account = scan_import.account
      update_vm_scan(scan_import, Qualys::Scan.get(account, reference))
    else
      handle_opts(scan_import, opts)
    end
  end

  # Handle Qualys API options
  # @param **scan_import:** ScanImport
  # @param **opts:** Qualys API options
  def handle_opts(scan_import, opts)
    account = scan_import.account
    KEYS.each do |opt_key|
      handle_empty_opts(opts, opt_key)
    end
    # Si :consultants on envoie le client name en filtre si au moins un
    if account.ext.consultants_kind?
      # En VM, on ne peut filtrer qu'un client_id par requête de recherche de scans,
      # il faut donc boucler sur la liste de clients ids
      if opts.key?(CLIENT_IDS)
        # On supprime le filtre s'il est vide => on veut tout récupérer
        if opts[CLIENT_IDS].empty?
          opts.delete(CLIENT_IDS)
          list_scans(scan_import, opts)
        else
          list_client_scans(opts[CLIENT_IDS], scan_import, opts)
        end
      else
        filter_client_ids(scan_import, opts)
      end
    else
      # Delete CLIENT_IDS if provided as it causes HTTP 400
      opts.delete(CLIENT_IDS)
      list_scans(scan_import, opts)
    end
  end

  private

  # Update VmScan with QualysVm::Scan infos
  # @param updatescan: VmScan
  # @param scan: QualysVm::Scan
  # @param scan_import: ScanImport
  # @param vmclient: VmClient found from scan.client_id
  def update_scan(updatescan, scan, scan_import, vmclient)
    updatescan.update!(QualysMapper.vm_scan_h(scan, scan_import, vmclient))
    Rails.logger.debug { "Qualys VM Scan Update #{updatescan.reference}: OK" }
  end

  # Create VmScan with QualysVm::Scan infos
  # @param scan: QualysVm::Scan
  # @param scan_import: ScanImport
  # @param vmclient: QualysVmClient if found from scan.client_id
  # @return **the created vm scan
  def create_vm_scan(scan, scan_import, vmclient)
    created_vm_scan = VmScan.create!(QualysMapper.vm_scan_h(scan, scan_import, vmclient))
    Rails.logger.debug { "Qualys VM Scan Creation #{scan.reference}: OK" }
    created_vm_scan
  end

  def handle_vm_occurrences(account, current_scan, scan)
    Qualys::ScanResult.fetch(account, scan.reference).results.each do |qualys_scan_result|
      vuln = Vulnerability.find_by(qid: qualys_scan_result.qid)
      next if vuln.nil?

      occ = VmOccurrence.create!(
        QualysMapper.vm_occurrence_h(vuln, qualys_scan_result, current_scan)
      )
      Rails.logger.debug { "VM Occurrence Creation #{occ.id}: OK" }
    end
  end

  # Supprime les filtres vides
  def handle_empty_opts(opts, opt_key)
    return unless opts.key?(opt_key)

    # On supprime le filtre s'il est vide
    opts.delete(opt_key) if opts[opt_key].empty?
  end

  def list_client_scans(client_ids, scan_import, opts)
    opts.delete(CLIENT_IDS)
    client_ids.each do |client_id|
      opts[:client_id] = client_id
      list_scans(scan_import, opts)
    end
  end

  def filter_client_ids(scan_import, opts)
    account = scan_import.account
    # On va chercher uniquement les clients ids si existants pour les set par défaut
    client_ids = account.qualys_vm_clients.flat_map(&:qualys_id)
    if client_ids.present?
      list_client_scans(client_ids, scan_import, opts)
    else
      # Si pas de client alors on ne filtre pas...
      list_scans(scan_import, opts)
    end
  end

  # Import one Qualys VmScan
  # @param **scan_import:** ScanImport
  # @param **scan:** Qualys::Scan
  def import_vm_scan(scan_import, scan)
    return if VmScan.find_by(reference: scan.reference).present?

    account = scan_import.account
    vmclient = QualysVmClient.find_by(qualys_id: scan.client_id, qualys_config_id: account.id)
    created_scan = create_vm_scan(scan, scan_import, vmclient)
    handle_vm_occurrences(account, created_scan, scan)
  end

  # Update one Qualys VmScan
  # @param **scan_import:** ScanImport
  # @param **scan:** Qualys::Scan
  def update_vm_scan(scan_import, scan)
    account = scan_import.account
    updatescan = VmScan.find_by(reference: scan.reference)
    return if updatescan.nil?

    vmclient = QualysVmClient.find_by(qualys_id: scan.client_id, qualys_config_id: account.id)
    update_scan(updatescan, scan, scan_import, vmclient)
  end

  # Fetch all Qualys scans with opts
  # @param **scan_import:** ScanImport
  # @param **opts:** Qualys API call options
  def list_scans(scan_import, opts)
    scans = Qualys::Scan.list(scan_import.account, opts)
    Rails.logger.debug { "Found #{scans.data.length} Vm Scans" }
    scans.data.each do |scan|
      send(:"#{@import_type}_vm_scan", scan_import, scan)
    end
  end
end
