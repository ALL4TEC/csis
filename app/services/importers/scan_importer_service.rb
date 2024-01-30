# frozen_string_literal: true

# Service d'import de scans provenant de fichiers et non d'API manuellement depuis un rapport
module Importers
  class ScanImporterService
    # return mappings
    attr_reader :mappings

    # used for logs
    attr_reader :scanner

    TODAY = Time.zone.now

    # @param base_class: classe de base utilisée pour parser le contenu
    # @param kind: :Vm or :Wa
    # @param mappings: Hash of mappings between scanner results and csis model
    # @param job: job créé à l'initialisation du perform
    def initialize(base_class, kind, mappings, job)
      @base_class = base_class
      @scanner = base_class.to_s
      @kind = kind
      @scan_sym = :"#{@kind}Scan"
      @occ_sym = :"#{@kind}Occurrence"
      @mappings = mappings
      @job = job
    end

    # Create occurrence from provided data
    # @param **created_scan:** Created scan
    # @param **vuln:** Presisted vulnerability
    # @param **occurrence:** Scanner corresponding occurrence object
    # @param **vulnerability:** Scanner corresponding vulnerability object
    def handle_occurrence_import(created_scan, vuln, occurrence, vulnerability)
      # Define alias on struct if specified to call from mappings
      if mappings[@occ_sym][:struct].present?
        define_alias(mappings[@occ_sym][:struct].singularize, occurrence)
      end
      # create_occurrence and attach to vulnerability and scan
      create_occurrence(created_scan, vuln, occurrence, vulnerability)
    end

    # Handle vulnerability and create occurrences for each corresponding objects
    # @param **created_scan:** Created scan
    # @param **vulnerability:** Scanner corresponding vulnerability object
    def handle_vuln_import(created_scan, vulnerability)
      define_alias(mappings[:Vulnerability][:struct].singularize, vulnerability)
      vuln = handle_vulnerability(vulnerability)
      # Define struct corresponding to a occurrence if specified
      occurrencies = to_struct(vulnerability, @occ_sym)
      occurrencies.each do |occurrence|
        handle_occurrence_import(created_scan, vuln, occurrence, vulnerability)
      end
    end

    # Create scan, handle vulnerabilities imports and occurrences creation for each corresponding
    # objects
    # @param **report_scan_import:** ReportScanImport to link import to
    # @param **scan:** Scanner corresponding scan object
    def handle_scan_import(report_scan_import, scan)
      # Definition d'un alias uniquement si non root
      define_alias(mappings[@scan_sym][:struct], scan) if mappings[@scan_sym][:struct].present?
      # Creation d'un Scan
      @job.update!(status: :"create_#{@kind.downcase}_scan")
      created_scan = create_scan(report_scan_import, scan)
      @job.update!(status: :handle_issues)
      # Define struct corresponding to a vulnerability
      vulnerabilities = to_struct(scan, :Vulnerability)
      vulnerabilities.each do |vulnerability|
        handle_vuln_import(created_scan, vulnerability)
      end
    end

    # Create scans, handle vulnerabilities imports and occurrences creation for each corresponding
    # objects
    # @param **report_scan_import:** ReportScanImport to link import to
    # @param **file:** File to read results from
    def handle_import(report_scan_import, file)
      Rails.logger.debug { "Opening file at: #{file.path}" }
      results = @base_class.send(:"from_#{mappings[:content_type]}!", file.read)
      @job.update!(status: :looking_for_issues)
      # Define struct corresponding to a #{@kind}_scan
      scans = to_struct(results, @scan_sym)
      scans.each do |scan|
        handle_scan_import(report_scan_import, scan)
      end
    end

    # Import scans from report_scan_import document
    # @param **report_scan_import:** ReportScanImport to link import to and to import from
    def import_scans(report_scan_import)
      report_scan_import.document.open do |file|
        @job.update!(status: :opening_document)
        handle_import(report_scan_import, file)
        @job.update!(status: :update_status)
        report_scan_import.scan_import.update(status: :completed)
      end
    end

    private

    # @param **report_scan_import:** ReportScanImport
    # @param **_scan:** Scanner corresponding scan model
    # @return **the created scan**
    def create_scan(report_scan_import, _scan)
      to_s_attr = :name
      scan_name = report_scan_import.scan_name.presence
      scan_name ||= instance_eval(mappings[@scan_sym][to_s_attr], __FILE__, __LINE__)
      scan_h = { import_id: report_scan_import.import_id }
      scan_h[to_s_attr] = scan_name
      mappings[@scan_sym].except(:struct, to_s_attr).each do |key, value|
        scan_h[key] = instance_eval(value, __FILE__, __LINE__)
      end
      created_scan = @scan_sym.to_s.constantize.create!(scan_h)
      if mappings[:Target].present?
        target_h = {}
        mappings[:Target].each do |key, value|
          target_h[key] = instance_eval(value, __FILE__, __LINE__)
        end
        target = Target.find_or_create_by!(target_h)
        created_scan.targets << target
      end
      Rails.logger.debug { "#{scanner}: #{@scan_sym} created: #{created_scan.id}" }
      report_h = { report_id: report_scan_import.report_id }
      report_h["#{@scan_sym}Id".underscore] = created_scan.id
      "Report#{@scan_sym}".constantize.create!(report_h)
      Rails.logger.debug do
        "#{scanner}: #{@scan_sym} linked to report #{report_scan_import.report_id}: OK"
      end
      created_scan
    end

    # TODO: Refactor to handle VM AND WA
    # Historically called when handling occurrences, as we created a VmTarget per vm_occurrence
    # Should be still the case but for the moment no vm scan needs it...
    # @param **created_scan:** The created scan
    # @return **the created Target**
    def create_report_scan_target(created_scan, target)
      # Target is automatically created after occurrence creation
      # If auto generation wanted, we must set ReportTarget for vm scans only
      report_scan_import = created_scan.scan_import.report_scan_import
      if report_scan_import.auto_aggregate?
        # Newly created scan contains only one report_vm_scan for the moment
        report_vm_scan = created_scan.report_vm_scans.first
        ReportTarget.find_or_create_by!(target: target, report_vm_scan: report_vm_scan) do |r_t|
          r_t.target = target
          r_t.report_vm_scan = report_vm_scan
        end
      end
      target
    end

    # Create Occurrence linked to vulnerability, filling data with _occ_data content
    # and _vuln_data
    def create_occurrence(created_scan, vulnerability, _occ_data, _vuln_data)
      occurrence_h = {
        vulnerability_id: vulnerability.id
      }
      occurrence_h[:scan] = created_scan
      mappings[@occ_sym].except(:struct).each do |key, value|
        occurrence_h[key] = instance_eval(value, __FILE__, __LINE__)
      end
      occ = @occ_sym.to_s.constantize.create!(occurrence_h)
      # Handle ReportXXScanTarget
      create_report_scan_target(created_scan, occ.target) if occ.vm?
      Rails.logger.debug { "#{scanner}: #{@occ_sym} Creation #{occ.id}: OK" }
      occ
    end

    def handle_vulnerability(vuln_data)
      qid = instance_eval(mappings[:Vulnerability][:qid], __FILE__, __LINE__)
      Rails.logger.debug { "#{scanner}: Looking for vulnerability with qid #{qid}" }
      vuln = Vulnerability.find_by(qid: qid)
      return vuln if vuln.present?

      # create vulnerability if not present
      Rails.logger.debug { "#{scanner}: Creating vulnerability with qid #{qid}" }
      # rubocop:disable Lint/UselessAssignment
      kind = map_kind(vuln_data)
      severity = map_severity(vuln_data)
      # rubocop:enable Lint/UselessAssignment
      vulnerability_h = {}
      mappings[:Vulnerability].except(:struct).each do |key, value|
        vulnerability_h[key] = instance_eval(value, __FILE__, __LINE__)
      end
      vuln = Vulnerability.create!(vulnerability_h)
      Rails.logger.debug { "#{scanner}: Created vulnerability with qid #{vuln.qid}" }
      vuln
    end

    # method to override per scanner
    def map_kind(_vuln_data)
      raise NotImplementedError
    end

    # method to override per scanner
    def map_severity(_vuln_data)
      raise NotImplementedError
    end

    # Ne définit un alias que sur la dernière méthode du nom
    # Ex: finding_attributes.someone crée un alias someone
    def define_alias(name, value)
      name = name.split('.').last
      define_singleton_method(name) { value }
    end

    # Get scanner result object corresponding to CSIS 'sym' model from scanner result object 'base'
    # by using mappings[sym][:struct] or simply returning an array
    # Applique mappings[sym][:struct] à base
    # de manière récursive si [:struct] contient un .
    # @param **base:** Source object to apply mappings[sym][:struct] on
    # @param **sym:** Symbol of CSIS model to struct
    # @return object to use in mappings for attributes evaluation linked to CSIS 'sym' model
    def to_struct(base, sym)
      reduced = base
      if mappings[sym][:struct].present?
        mappings[sym][:struct].split('.').each do |method|
          reduced = reduced.send(method)
        end
        reduced = [reduced] unless reduced.respond_to?(:each)
      else
        reduced = [base]
      end
      reduced
    end
  end
end
