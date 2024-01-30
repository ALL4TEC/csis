# frozen_string_literal: true

require 'test_helper'
require 'jobs/importers/cyberwatch/job_test_helper'

class Importers::Cyberwatch::Vm::ScansImportJobTest < ActiveJob::TestCase
  include Importers::Cyberwatch::JobTestHelper

  test 'VmScans and occurrences are correctly imported' do
    prev_assets = Asset.count
    prev_vs = VmScan.count
    prev_vo = VmOccurrence.count
    account = cyberwatch_configs(:cbw_one)
    scans_imports_count = account.scans_imports.count

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        # We need assets & vulns
        Importers::Cyberwatch::AssetsImportJob.perform_now(nil, account.id)
        Importers::Cyberwatch::VulnerabilitiesImportJob.perform_now(nil, account.id)
        # We can import the scans
        Importers::Cyberwatch::Vm::ScansImportJob.perform_now(nil, account.id)
      else
        account.reload
        assert_equal 4, Asset.count - prev_assets
        assert_equal 1, account.scans_imports.count - scans_imports_count
        last_scan_import = account.scans_imports.last
        assert_equal 4, VmScan.count - prev_vs # 4 created vm_scans
        assert_equal 4, last_scan_import.vm_scans.count
        assert_equal 0, last_scan_import.wa_scans.count
        assert_not_equal prev_vo, VmOccurrence.count # VmOccurrence created
      end
    end
  end
end
