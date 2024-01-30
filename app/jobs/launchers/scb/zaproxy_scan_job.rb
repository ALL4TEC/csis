# frozen_string_literal: true

# Job launching zaproxy wa scans
module Launchers
  class Scb::ZaproxyScanJob < ApplicationKubeScan
    attr_reader :scan_launch, :creator

    def init_args
      @scan_launch = arguments[0]
    end

    def manifest
      pre_params = ['-t', @scan_launch.target]
      post_params = ['-d', '-m', '2']
      splitted_params = @scan_launch.parameters.split
      all_params = pre_params + splitted_params + post_params

      {
        'apiVersion' => 'execution.securecodebox.io/v1',
        'kind' => 'Scan',
        'metadata' => {
          'name' => "#{@scan_launch.scan_type}-#{INSTANCE_NAME}",
          'labels' => {
            'organization' => 'OWASP',
            'scan-launch-id' => @scan_launch.id.to_s
          }
        },
        'spec' => {
          'scanType' => @scan_launch.scan_type.to_s,
          'parameters' => all_params
        }
      }
    end

    def perform(scan_launch)
      logger.info(
        "#{scan_launch.scan_type} on #{scan_launch.target} for #{scan_launch.report.title}\
        started."
      )
    end
  end
end
