# frozen_string_literal: true

require 'test_helper'
require 'jobs/importers/qualys/job_test_helper'

class Importers::Qualys::Vm::ScansImportJobTest < ActiveJob::TestCase
  include Importers::Qualys::JobTestHelper

  def setup
    # Clean stubbed data from db
    VmScan.where(id: %i[vm_scan_three].map { |key| vm_scans(key).id }).delete_all # cascade
    # VmOccurrence.where(id: %i[four].map { |key| vm_occurrences(key).id }).delete_all
  end

  test 'VmScans and occurrences are correctly imported w\out client id if not linked to account' do
    prev_vs = VmScan.count
    prev_ws = WaScan.count
    prev_vo = VmOccurrence.count
    prev_wo = WaOccurrence.count
    account = qualys_configs(:qc_two)
    scans_imports_count = account.scans_imports.count

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        Importers::Qualys::Vm::ScansImportJob.perform_now(nil, account.id)
      else
        account.reload
        assert_equal 1, account.scans_imports.count - scans_imports_count
        last_scan_import = account.scans_imports.last
        assert_equal 3, VmScan.count - prev_vs # 3 created vm_scans
        assert_equal 0, WaScan.count - prev_ws # 0 created wa_scans
        assert_equal 3, last_scan_import.vm_scans.count
        assert_equal 0, last_scan_import.wa_scans.count
        # QualysConfig is set in Scan
        assert_equal 8, VmScan.where.not(account_id: nil).count # 6 - 1 + 3
        assert_equal 11, WaScan.where.not(account_id: nil).count # 6 + 5(ias)
        # No qualys_xx_client_id set as none is related to qualys_config two
        assert_equal 3, VmScan.where.not(qualys_vm_client_id: nil).count # 4 - 1
        assert_equal 5, WaScan.where.not(qualys_wa_client_id: nil).count # 5
        assert_not_equal prev_vo, VmOccurrence.count # VmOccurrence created
        assert_equal prev_wo, WaOccurrence.count # No WaOccurrence created
      end
    end
  end

  test 'VmScans and occurrences are well imported and with client id set if linked to account' do
    prev_vs = VmScan.count
    prev_ws = WaScan.count
    prev_vo = VmOccurrence.count
    prev_wo = WaOccurrence.count
    account = qualys_configs(:qc_one)
    scans_imports_count = account.scans_imports.count

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        Importers::Qualys::Vm::ScansImportJob.perform_now(nil, account.id)
      else
        account.reload
        assert_equal 1, account.scans_imports.count - scans_imports_count
        last_scan_import = account.scans_imports.last
        assert_equal 3, VmScan.count - prev_vs # 3 created vm_scans
        assert_equal 0, WaScan.count - prev_ws # 0 created wa_scans
        assert_equal 3, last_scan_import.vm_scans.count
        assert_equal 0, last_scan_import.wa_scans.count
        # QualysConfig is set in Scan
        assert_equal 8, VmScan.where.not(account_id: nil).count # 6 - 1 + 3
        assert_equal 11, WaScan.where.not(account_id: nil).count # 6 + 5(ias)
        # 3 qualys_xx_client_id set as all are related to qualys_config one
        assert_equal 6, VmScan.where.not(qualys_vm_client_id: nil).count # 4 - 1 + 3
        assert_equal 5, WaScan.where.not(qualys_wa_client_id: nil).count # 5
        assert_not_equal prev_vo, VmOccurrence.count # VmOccurrence created
        assert_equal prev_wo, WaOccurrence.count # No WaOccurrence created
      end
    end
  end
end
