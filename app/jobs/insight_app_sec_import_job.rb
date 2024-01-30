# frozen_string_literal: true

# Job importing InsightAppSec scans
class InsightAppSecImportJob < ApplicationKubeJob
  def perform(_creator, account)
    logger.debug "Insight App Sec Import Job with account: #{account}"
    import_scans(account)
    logger.debug 'Insight App Sec import : OK'
  end

  private

  def import_scans(_account)
    # TODO
  end
end
