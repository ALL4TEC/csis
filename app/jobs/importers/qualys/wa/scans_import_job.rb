# frozen_string_literal: true

module Importers
  module Qualys
    module Wa
      # Job importing wa scans
      # Import only scans related to WaClient specified in csis
      class ScansImportJob < ApplicationKubeJob
        def perform(creator_id, account_id, opts = {})
          account = QualysConfig.find(account_id)
          job_h = {
            subscribers: account.teams.flat_map(&:staffs),
            progress_steps: 1
          }
          job_h[:creator] = User.find(creator_id) if creator_id.present?
          handle_perform(job_h) do |job|
            logger.debug "#{self.class} with account: #{account}, options: #{opts}"
            scan_import = ScanImport.create(
              status: :scheduled, import_type: :qualys, account: account
            )
            ScansImporterService.import_wa_scans(scan_import, opts)
            logger.debug "#{self.class}: OK"
            job.update!(status: :completed)
          end
        end
      end
    end
  end
end
