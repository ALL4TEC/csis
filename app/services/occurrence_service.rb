# frozen_string_literal: true

class OccurrenceService
  class << self
    # Select wa occurrences linked to wa_scan_ids
    # @param **wa_scan_ids:**
    def select_wa_occurrences(wa_scan_ids)
      WaOccurrence.where(scan_id: wa_scan_ids)
    end

    # Select vm occurrences linked to vm_scan_ids
    # @param **clazz:** Report type
    # @param **vm_scan_ids:**
    def select_vm_occurrences(clazz, vm_scan_ids, targets = [])
      if clazz == ScanReport
        VmOccurrence.where(scan_id: vm_scan_ids, ip: targets.map(&:ip))
      elsif clazz == PentestReport
        VmOccurrence.where(scan_id: vm_scan_ids)
      end
    end

    def select_occurrences_of_vulnerability_kind(occurrences, kind)
      occurrences.select(&OccurrenceLambda.only_same_vulnerability_kind(kind))
    end

    def sort_by_severity(occurrences)
      occurrences.sort_by do |occurrence|
        5 - Vulnerability.severities[occurrence.vulnerability.severity]
      end
    end
  end
end
