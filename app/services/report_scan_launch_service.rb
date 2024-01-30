# frozen_string_literal: true

class ReportScanLaunchService
  SCANNERS = {
    zaproxy: Importers::Scb::ZaproxyImportJob
  }.freeze

  class << self
    def launch_import(scan_launch, importer)
      Rails.logger.info("Launching #{scan_launch} import.")
      scanner = scan_launch.scanner
      # Create import entities before triggering import
      scan_import = ScanImport.create!(
        importer: importer, import_type: scanner, scan_launch: scan_launch
      )
      # Report scan import creation linked to specified report
      report_scan_import = ReportScanImport.create!(
        report: scan_launch.report, scan_import: scan_import, document: scan_launch.result.blob,
        scan_name: scan_launch.scan_name,
        auto_aggregate: scan_launch.auto_aggregate,
        auto_aggregate_mixing: scan_launch.auto_aggregate_mixing
      )
      scanner_type = scanner.to_sym
      if SCANNERS.key?(scanner_type)
        SCANNERS[scanner_type].perform_later(report_scan_import)
      else
        Rails.logger.error "#{scan_launch} import but cannot find scanner to import."
      end
    end

    def save_scan_launch_data(scan_launch, data)
      filename = "#{scan_launch.scan_type}-#{scan_launch.id}"
      tmp = Tempfile.new([filename, '.json'])
      File.open(tmp.path, 'w+b') do |f|
        f.write(data)
        f.rewind
        blob = ActiveStorage::Blob.create_and_upload!(
          io: f,
          filename: "#{filename}.json",
          content_type: 'application/json',
          identify: false
        )
        scan_launch.update!(result: blob)
      end
      tmp.unlink
    end
  end
end
