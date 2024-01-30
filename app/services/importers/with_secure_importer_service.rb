# frozen_string_literal: true

module Importers
  class WithSecureImporterService
    def initialize(job)
      @job = job
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

    def handle_exploit_src(exploit_src_id_format, ws_xref)
      ExploitSource.find_or_create_by!(id_format: exploit_src_id_format) do |src_record|
        src_record.name = exploit_src_id_format
        src_record.exploits_root_url = ws_xref.url
      end
    end

    # Find or create exploit
    # @param **ws_exploit_id:** WithSecure Exploit identifier
    # @param **ws_xref:** WithSecure exploit cross ref
    # @return persisted Exploit
    def handle_exploit(ws_exploit_id, ws_xref)
      # Find or create exploit source from ws_exploit_id
      exploit_src = nil
      if ws_exploit_id.contains(':')
        exploit_src_id_format = ws_exploit_id.split(':').first
        exploit_src = handle_exploit_src(exploit_src_id_format, ws_xref)
      end
      Exploit.find_or_create_by!(reference: ws_exploit_id, link: ws_xref.url) do |record|
        record.reference = ws_exploit_id
        record.link = ws_xref.url
        record.exploit_source = exploit_src
      end
    end

    # Import exploits
    # @param **ws_plugin:** WithSecure plugin data
    # @return ws_plugin related and persisted exploits list
    def import_exploits(ws_plugin)
      ws_plugin.exploits.map do |exploit_id|
        # Find corresponding xref
        ws_xref = ws_plugin.xrefs.find { |xref| xref.description == exploit_id }
        handle_exploit(exploit_id, ws_xref)
      end
    end

    # @param **report_scan_import:** ReportScanImport
    # @param **ws_scan_report:** WithSecure scan report
    # @return **the created scan**
    def create_scan(report_scan_import, ws_scan_report)
      created_scan = VmScan.create!(WithSecureMapper.scan_h(report_scan_import, ws_scan_report))
      # Targets can be created here or at vm_occurrence creation
      Rails.logger.debug { "WithSecure: VmScan created: #{created_scan.id}" }
      ReportVmScan.create!({
        report_id: report_scan_import.report_id,
        vm_scan_id: created_scan.id
      })
      Rails.logger.debug do
        "WithSecure: VmScan linked to report #{report_scan_import.report_id}: OK"
      end
      created_scan
    end

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

    # Create Occurrence linked to vulnerability
    # @param **created_scan:** Created scan
    # @param **vulnerability:** Found or created vulnerability to be linked to occurrence
    # @param **ip:** Target ip
    def create_occurrence(created_scan, vulnerability, ip)
      occ = VmOccurrence.create!(WithSecureMapper.occurrence_h(created_scan, vulnerability, ip))
      # Handle ReportXXScanTarget
      create_report_scan_target(created_scan, occ.target)
      Rails.logger.debug { "WithSecure: VmOccurrence #{occ.id}: Created" }
      occ
    end

    # Find or create a Vulnerability corresponding to ws_host data
    # @param **ws_vulnerability:** WithSecure host vulnerability data
    # @param **ws_plugin:** WithSecure scanner vulnerability
    # @return **Found or created vulnerability**
    def handle_vulnerability(ws_vulnerability, ws_plugin)
      qid = "WithSecure-#{ws_plugin.id}"
      Rails.logger.debug { "WithSecure: Looking for vulnerability with qid #{qid}" }
      vuln = Vulnerability.find_by(qid: qid)
      return vuln if vuln.present?

      # create vulnerability if not present
      Rails.logger.debug { "WithSecure: Creating vulnerability with qid #{qid}" }
      # Creating exploits from xrefs if exploitable
      exploits = ws_plugin.exploitable == 'True' ? import_exploits(ws_plugin) : []
      vuln = Vulnerability.create!(
        WithSecureMapper.vulnerability_h(ws_vulnerability, ws_plugin, exploits)
      )
      Rails.logger.debug { "WithSecure: Created vulnerability with qid #{vuln.qid}" }
      vuln
    end

    # Create occurrence from provided data
    # @param **created_scan:** Created scan
    # @param **vuln:** Persisted vulnerability
    # @param **ip:** Target ip
    def handle_occurrence_import(created_scan, vuln, ip)
      create_occurrence(created_scan, vuln, ip)
    end

    # Handle vulnerability and create occurrences for each corresponding objects
    # @param **created_scan:** Created scan
    # @param **ws_host:** WithSecure scan report host data
    def handle_vuln_import(created_scan, ws_host, ws_plugins)
      ws_host.vulnerabilities.each do |ws_vuln|
        # Find corresponding ws_plugin
        ws_plugin = ws_plugins.find { |plugin| plugin.id == ws_vuln.id }
        vuln = handle_vulnerability(ws_vuln, ws_plugin)
        handle_occurrence_import(created_scan, vuln, ws_host.title)
      end
    end

    # Create scan, handle vulnerabilities imports and occurrences creation for each corresponding
    # objects
    # @param **report_scan_import:** ReportScanImport to link import to
    # @param **ws_scan_report:** WithSecure scan report data
    def handle_scan_import(report_scan_import, ws_scan_report)
      # Creation d'un Scan
      @job.update!(status: :create_vm_scan)
      created_scan = create_scan(report_scan_import, ws_scan_report)
      @job.update!(status: :handle_issues)
      # Need to pass ws_plugin data as used for vulnerability creation
      ws_plugins = ws_scan_report.plugins.platform.plugins
      # Loop over hosts to create vm_occurrences and linked vulnerability
      ws_scan_report.platform.hosts.each do |ws_host|
        # Find or create vulnerability from ws_host data
        handle_vuln_import(created_scan, ws_host, ws_plugins)
      end
    end

    # Create scans, handle vulnerabilities imports and occurrences creation for each corresponding
    # objects
    # @param **report_scan_import:** ReportScanImport to link import to
    # @param **file:** File to read results from
    def handle_import(report_scan_import, file)
      Rails.logger.debug { "Opening file at: #{file.path}" }
      ws_scan_report = WithSecure::Report.from_xml!(file.read)
      @job.update!(status: :looking_for_issues)
      handle_scan_import(report_scan_import, ws_scan_report)
    end
  end
end
