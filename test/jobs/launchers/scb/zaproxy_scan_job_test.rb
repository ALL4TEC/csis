# frozen_string_literal: true

require 'test_helper'

module Launchers
  class FakeScansClient
    RESPONSE = {
      'metadata' => {
        'uid' => 'someuuid'
      }
    }.freeze

    def create_scan(*_args)
      RESPONSE
    end
  end

  class Scb::ZaproxyScanJobTest < ActiveJob::TestCase
    def setup
      Resque::Kubernetes.enabled = true
    end

    def teardown
      Resque::Kubernetes.enabled = false
    end

    test 'Zaproxy scan is correctly launched' do
      # Stubbing ScansManager needed methods
      stub_scan_manager
      report = scan_reports(:mapui)
      scan_configuration = ScanConfiguration.create!(
        scanner: :zaproxy, launcher: users(:staffuser), scan_type: 'zap-full-scan',
        target: 'http://something', parameters: '-a, -j, -f openapi'
      )
      scan_launch = ScanLaunch.create!(
        report: report,
        scan_configuration: scan_configuration
      )
      Scb::ZaproxyScanJob.perform_later(scan_launch)
      # Check manifest
      assert_equal 'launched', scan_launch.status
      assert_equal FakeScansClient::RESPONSE['metadata']['uid'], scan_launch.kube_scan_id
    end

    private

    def stub_scan_manager
      SecureCodeBox::Kubernetes::ScansManager.any_instance.stubs(
        :delete_finished_scans_jobs_and_associated_pods
      ).returns(nil)
      SecureCodeBox::Kubernetes::ScansManager.any_instance.stubs(:scans_maxed?).returns(false)
      SecureCodeBox::Kubernetes::ScansManager.any_instance.stubs(:scans_client).returns(
        FakeScansClient.new
      )
    end
  end
end
