# frozen_string_literal: true

module Scb
  class ScanResultMapper
    class << self
      def find_scan_status_findings_count(json_content)
        json_content['scan']['status']['findings']['count']
      end

      def find_scan_launch_id(json_content)
        json_content['scan']['metadata']['labels']['scan-launch-id']
      end
    end
  end
end
