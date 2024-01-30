# frozen_string_literal: true

require 'test_helper'

class DestructorJobTest < ActiveJob::TestCase
  test 'correctly destroy scan_import' do
    scan_import = scan_imports(:scan_import_one)
    DestructorJob.perform_now(users(:staffuser), scan_import)
    assert_raise ActiveRecord::RecordNotFound do
      ScanImport.find(scan_import.id)
    end
  end
end
