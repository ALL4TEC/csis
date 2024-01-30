# frozen_string_literal: true

require 'tempfile'

# Provide methods to clone a wa or vm scan
# including nested objects (occurrences and targets)
module ScanCloner
  def clone_wa_scan_and_add_vuln_two(scan)
    new_scan = scan.dup
    new_scan.reference = "was_auto/#{SecureRandom.hex(6)}"
    new_scan.launched_at = 1.week.ago
    scan.occurrences.each do |occurrence|
      clone_wa_occurrence(new_scan, occurrence)
    end
    new_scan.save!
    # new_scan has same occurrences
    assert OccurrenceComparator.equals?(scan.occurrences, new_scan.occurrences)
    # + another
    new_wa_occurrence = WaOccurrence.create!(
      {
        scan: new_scan,
        vulnerability: vulnerabilities(:vulnerability_two),
        result: 'result',
        uri: 'uri'
      }
    )
    new_scan.reload
    assert new_wa_occurrence.in?(new_scan.occurrences)
    assert_equal 0, new_scan.reports.count
    new_scan
  end

  def clone_wa_occurrence(new_scan, occurrence_src)
    wa_occurrence_clone = occurrence_src.dup
    wa_occurrence_clone.scan = new_scan
    wa_occurrence_clone.save!
    wa_occurrence_clone
  end

  def clone_vm_scan_and_add_vuln_two(scan)
    new_scan = scan.dup
    new_scan.reference = "vm_auto/#{SecureRandom.hex(6)}"
    new_scan.launched_at = 1.week.ago
    new_scan.save!
    # Scan target is created if not existing at occurrence creation
    # scan.targets.each do |target|
    #   clone_vm_target(new_scan, target)
    # end
    scan.occurrences.each do |occurrence|
      new_scan.occurrences << clone_vm_occurrence(new_scan, occurrence)
    end
    # new_scan has same occurrences
    new_scan.reload
    assert_equal new_scan.targets, scan.targets
    assert OccurrenceComparator.equals?(scan.occurrences, new_scan.occurrences)
    # + another
    new_vm_occurrence = VmOccurrence.create!(
      {
        scan: new_scan,
        vulnerability: vulnerabilities(:vulnerability_two),
        ip: new_scan.occurrences.first.ip # Without it, occurrence won't be selected
      }
    )
    new_scan.reload
    assert new_vm_occurrence.in?(new_scan.occurrences)
    assert_equal 0, new_scan.reports.count
    new_scan
  end

  def clone_vm_target(new_scan, target_src)
    new_vm_target = target_src.dup
    new_vm_target.vm_scans << new_scan
    new_vm_target.save!
    new_vm_target
  end

  def clone_vm_occurrence(new_scan, occurrence_src)
    vm_occurrence_clone = occurrence_src.dup
    vm_occurrence_clone.scan = new_scan
    vm_occurrence_clone.save!
    vm_occurrence_clone
  end
end
