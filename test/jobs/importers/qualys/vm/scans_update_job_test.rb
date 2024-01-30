# frozen_string_literal: true

require 'test_helper'
require 'jobs/importers/qualys/job_test_helper'

class Importers::Qualys::Vm::ScansUpdateJobTest < ActiveJob::TestCase
  include Importers::Qualys::JobTestHelper

  ASSERTS = {
    name: {
      vm_scan_three: 'VM - Test - 8.8.8.8 - 2019-04-06'
    }
  }.freeze

  test 'Scans and occurrences are correctly updated' do
    test_update(1)
  end

  private

  def test_update(related_scans_count)
    # GIVEN
    account = QualysConfig.first
    scan_imports_count = account.scans_imports.count
    prev_ws = VmScan.count
    prev_wo = VmOccurrence.count

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        Importers::Qualys::Vm::ScansUpdateJob.perform_now(nil, QualysConfig.first.id, nil, {})
      else
        # New Scan_import
        account.reload
        assert_equal 1, account.scans_imports.count - scan_imports_count
        assert_equal related_scans_count, account.scans_imports.last.vm_scans.count
        # No scan created
        assert_equal 0, VmScan.count - prev_ws
        # Check updated fields
        assert_names
        # No VmOccurrence created
        assert_equal prev_wo, VmOccurrence.count
      end
    end
  end

  # Check that each name of ASSERTS is "#{arg}_equal" to vm_scans().name
  def assert_names(arg = '')
    make_asserts(:name, 'scans', arg)
  end

  def make_asserts(kind, object, arg)
    ass = "assert#{arg}_equal"
    obj = "vm_#{object}"
    ASSERTS[kind].each_key do |key|
      send(ass, ASSERTS[kind][key], send(obj, key).send(kind.to_s))
    end
  end
end
