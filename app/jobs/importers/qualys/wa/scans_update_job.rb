# frozen_string_literal: true

module Importers
  module Qualys
    module Wa
      # Job updating Qualys WaScans
      # Can update one WaScan if passing qualys reference
      # Can only update thumbnails and force update
      class ScansUpdateJob < ApplicationKubeJob
        # @param creator_id: creator id
        # @param account_id: QualysConfig account id
        # @param reference: Qualys internal_id, default: nil
        # @param only_thumbnail: update only thumbnails, default: false
        # @param force_thumbnail: force thumbnails update, default: false
        def perform(creator_id, account_id, reference = nil, options = {},
          only_thumbnail: false, force_thumbnail: false)
          account = QualysConfig.find(account_id)
          job_h = {
            subscribers: account.teams.flat_map(&:staffs),
            progress_steps: 1
          }
          job_h[:creator] = User.find(creator_id) if creator_id.present?
          handle_perform(job_h) do |job|
            logger.debug(
              "Updating Qualys WaScans(only:#{only_thumbnail}," \
              "force:#{force_thumbnail}," \
              "reference:#{reference})," \
              "options:#{options}"
            )
            scan_import = ScanImport.create(
              status: :scheduled, import_type: :qualys, account: account
            )
            ScansImporterService.update_wa_scans(scan_import, reference, options,
              only_thumbnail: only_thumbnail, force_thumbnail: force_thumbnail)
            logger.debug 'Qualys WA Scans Update : OK'
            job.update!(status: :completed)
          end
        end
      end
    end
  end
end
