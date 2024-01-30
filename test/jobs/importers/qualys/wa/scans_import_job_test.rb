# frozen_string_literal: true

require 'test_helper'
require 'jobs/importers/qualys/job_test_helper'

class Importers::Qualys::Wa::ScansImportJobTest < ActiveJob::TestCase
  include Importers::Qualys::JobTestHelper

  def setup
    WaScan.where(id: %i[wa_scan_three wa_scan_four wa_scan_five].map { |key| wa_scans(key).id })
          .delete_all
    WaOccurrence.where(
      id: %i[wa_occurrence_five wa_occurrence_six wa_occurrence_seven].map do |key|
        wa_occurrences(key).id
      end
    ).delete_all
  end

  test 'WaScans and occurrences are correctly imported w\out client id if not linked to account' do
    # GIVEN
    prev_vs = VmScan.count
    prev_ws = WaScan.count
    prev_vo = VmOccurrence.count
    prev_wo = WaOccurrence.count
    account = qualys_configs(:qc_two)
    scans_imports_count = account.scans_imports.count

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        Importers::Qualys::Wa::ScansImportJob.perform_now(nil, account.id)
      else
        account.reload
        assert_equal 1, account.scans_imports.count - scans_imports_count
        last_scan_import = account.scans_imports.last
        assert_equal 0, VmScan.count - prev_vs # 0 created vm_scans
        assert_equal 3, WaScan.count - prev_ws # 3 created wa_scans
        assert_equal 0, last_scan_import.vm_scans.count
        assert_equal 3, last_scan_import.wa_scans.count
        # QualysConfig is set in Scan
        assert_equal 6, VmScan.where.not(account_id: nil).count # 5 + auto
        assert_equal 11, WaScan.where.not(account_id: nil).count # 5 - 3 + 3 + auto + 5 (ias)
        # No qualys_xx_client_id set as none is related to qualys_config two
        assert_equal 4, VmScan.where.not(qualys_vm_client_id: nil).count # 3 + auto
        assert_equal 2, WaScan.where.not(qualys_wa_client_id: nil).count # 5 - 3
        assert_equal prev_vo, VmOccurrence.count # No VmOccurrence created
        assert_not_equal prev_wo, WaOccurrence.count # WaOccurrence created
      end
    end
  end

  test 'WaScans and occurrences are well imported and with client id set if linked to account' do
    # GIVEN
    prev_vs = VmScan.count
    prev_ws = WaScan.count
    prev_vo = VmOccurrence.count
    prev_wo = WaOccurrence.count
    account = qualys_configs(:qc_one)
    scans_imports_count = account.scans_imports.count

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        Importers::Qualys::Wa::ScansImportJob.perform_now(nil, account.id)
      else
        account.reload
        assert_equal 1, account.scans_imports.count - scans_imports_count
        last_scan_import = account.scans_imports.last
        assert_equal 0, VmScan.count - prev_vs # 0 created vm_scans
        assert_equal 3, WaScan.count - prev_ws # 3 created wa_scans
        assert_equal 0, last_scan_import.vm_scans.count
        assert_equal 3, last_scan_import.wa_scans.count
        # QualysConfig is set in Scan
        assert_equal 6, VmScan.where.not(account_id: nil).count # 5 + auto
        assert_equal 11, WaScan.where.not(account_id: nil).count # 5 - 3 + 3 + auto + 5(ias)
        # 3 qualys_xx_client_id set as all are related to qualys_config one
        assert_equal 4, VmScan.where.not(qualys_vm_client_id: nil).count # 3 + auto
        assert_equal 5, WaScan.where.not(qualys_wa_client_id: nil).count # 5 - 3 + 3
        assert_equal prev_vo, VmOccurrence.count # No VmOccurrence created
        assert_not_equal prev_wo, WaOccurrence.count # WaOccurrence created
      end
    end
  end
end
