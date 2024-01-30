# frozen_string_literal: true

module Importers
  module Cyberwatch
    # Job importing cyberwatch vulnerabilities
    class VulnerabilitiesImportJob < ApplicationKubeJob
      def perform(creator_id, account_id, opts = {})
        account = CyberwatchConfig.find(account_id)
        job_h = {
          subscribers: account.teams.flat_map(&:staffs),
          progress_steps: 1
        }
        job_h[:creator] = User.find(creator_id) if creator_id.present?
        handle_perform(job_h) do |job|
          logger.debug "#{self.class} with account: #{account} and options: #{opts}"
          vulnerability_import = VulnerabilityImport.create(
            status: :scheduled, import_type: :cyberwatch, account: account
          )
          VulnerabilitiesImporterService.import_vulnerabilities(
            vulnerability_import, opts
          )
          logger.debug "#{self.class}: OK"
          job.update!(status: :completed)
        end
      end
    end
  end
end
