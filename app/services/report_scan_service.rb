# frozen_string_literal: true

class ReportScanService
  class << self
    # @param **scan:** VmScan
    # @param **report:** Report to compare scan targets with
    # @return scan.targets if no report, else common targets
    def select_common_vm_scan_targets_with_report(scan, report)
      return scan.targets if report.blank?

      scan.targets.select(&TargetLambda.only_containing_ip(report.targets.pluck(:ip)))
    end

    # TODO: REFACTO using targets
    # @param **scan:** WaScan
    # @param **report:** Report to compare scan targets with
    # @return scan.url if no report, else common urls
    def select_common_wa_scan_url_with_report(scan, report)
      return scan.url if report.blank?

      # scan.targets.select(&TargetLambda.only_containing_ip(report.targets.pluck(:url)))
      ReportWaScan.find_by(report: report, wa_scan: scan)&.web_app_url
    end

    # @param **scan:** The scan to take targets from
    # @param **new_report:** New report to set wa scan targets
    def set_new_report_wa_scan_targets(scan, new_report, previous_report)
      url = select_common_wa_scan_url_with_report(scan, previous_report)
      ReportWaScan.find_by(report: new_report, wa_scan: scan).update!(web_app_url: url)
    end

    # @param **scan:** The scan to take targets from
    # @param **new_report:** New report to set vm scan targets
    # @param **previous_report:** Previous report to select common vm scan targets from to set
    # targets if provided
    # @param **targets:** Vm targets to set to ReportVmScan if provided
    def set_new_report_vm_scan_targets(scan, new_report, previous_report = nil, targets = nil)
      targets ||= select_common_vm_scan_targets_with_report(scan, previous_report)
      ReportVmScan.find_by(report: new_report, vm_scan: scan).update!(targets: targets)
    end
  end
end
