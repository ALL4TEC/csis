# frozen_string_literal: true

require 'test_helper'
require 'jobs/importers/qualys/job_test_helper'

class Importers::Qualys::Wa::ScansUpdateJobTest < ActiveJob::TestCase
  include Importers::Qualys::JobTestHelper

  ASSERTS = {
    name: {
      wa_scan_three: 'Web Application Discovery Scan - france.bzh - 2017-05-10',
      wa_scan_four: 'Web Application Vulnerability Scan - 2017-06-05',
      wa_scan_five: 'Web Application Vulnerability Scan - 2017-06-05 - MonSite.Fr'
    },
    result: {
      wa_occurrence_five: '<br>Update Was<br>Something5',
      wa_occurrence_six: '<br>Update Was<br>Something6',
      wa_occurrence_seven: '<br>Update Was<br>Something7'
    }
  }.freeze
  FILE_NAME = 'fondPDF.jpeg'
  NOT = '_not'

  test 'Scans and occurrences are correctly updated' do
    test_update(3)
  end

  test 'Scans and occurrences thumbnails only are correctly updated' do
    test_update(0, only: true)
  end

  test 'Scans and occurrences thumbnails only are correctly updated when forcing' do
    test_update(0, only: true, force: true)
  end

  private

  def test_update(related_scans_count, only: false, force: false)
    # GIVEN
    account = QualysConfig.first
    scan_imports_count = account.scans_imports.count
    prev_ws = WaScan.count
    prev_wo = WaOccurrence.count

    # Attaching image to wa_scans
    attach_images_to_wa_scans if only

    # Assert already attached files
    check_attachments if only

    launch_test_with_stub do |arg|
      if arg == 'cmd'
        Importers::Qualys::Wa::ScansUpdateJob.perform_now(nil, account.id, nil,
          only_thumbnail: only, force_thumbnail: force)
      else
        # New Scan_import
        account.reload
        assert_equal 1, account.scans_imports.count - scan_imports_count
        assert_equal related_scans_count, account.scans_imports.last.wa_scans.count
        # No scan created
        assert_equal 0, WaScan.count - prev_ws
        # Check updated fields
        arg = only ? NOT : ''
        assert_names(arg)
        # Check attachments
        check = force ? NOT : ''
        check_attachments(check) if only
        # No WaOccurrence created
        assert_equal prev_wo, WaOccurrence.count
        # Check updated fields
        assert_results(arg)
      end
    end
  end

  # Check that each name of ASSERTS is "#{arg}_equal" to wa_scans().name
  def assert_names(arg = '')
    make_asserts(:name, 'scans', arg)
  end

  # Check that each name of ASSERTS is "#{arg}_equal" to wa_occurrences().result
  def assert_results(arg = '')
    make_asserts(:result, 'occurrences', arg)
  end

  def make_asserts(kind, object, arg)
    ass = "assert#{arg}_equal"
    obj = "wa_#{object}"
    ASSERTS[kind].each_key do |key|
      send(ass, ASSERTS[kind][key], send(obj, key).send(kind.to_s))
    end
  end

  def attach_images_to_wa_scans
    ASSERTS[:name].each_key do |index|
      scan = WaScan.qualys.find(wa_scans(index).id)
      scan.landing_page.attach(
        io: Rails.root.join('test/fixtures/files/settings/fondPDF.jpg').open,
        filename: FILE_NAME,
        content_type: 'image/jpeg'
      )
      scan.landing_page.save!
    end
  end

  def check_attachments(arg = '')
    ass = "assert#{arg}_equal"
    ASSERTS[:name].each_key do |index|
      scan = WaScan.qualys.find(wa_scans(index).id)
      assert_equal true, scan.landing_page.attached?
      send(ass, FILE_NAME, scan.landing_page.attachment.filename.to_s)
    end
  end
end
