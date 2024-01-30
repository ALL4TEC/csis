# frozen_string_literal: true

module Importers
  module Qualys
    class VulnerabilitiesImportJob < ApplicationKubeJob
      def perform(creator_id, account_id, last: false)
        account = QualysConfig.find(account_id)
        job_h = {
          subscribers: account.teams.flat_map(&:staffs),
          progress_steps: 1
        }
        job_h[:creator] = User.find(creator_id) if creator_id.present?
        handle_perform(job_h) do |job|
          logger.debug("#{self.class}: Begin for account: #{account} (last: #{last})")
          vulnerability_import = VulnerabilityImport.create(
            status: :scheduled, import_type: :qualys, account: account
          )
          VulnerabilitiesImporterService.import_vulnerabilities(
            vulnerability_import, last
          )
          logger.debug "#{self.class}: OK"
          job.update!(status: :completed)
        end
      end
    end
  end
end
