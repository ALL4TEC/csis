# frozen_string_literal: true

# Job updating WaScans
# Can update one WaScan if passing ias reference
class InsightAppSecUpdateJob < ApplicationKubeJob
  # @param account: InsightAppSecConfig account
  # @param reference: InsightAppSec internal_id, default: nil
  def perform(_creator, account, reference = nil)
    logger.debug("Updating InsightAppSec WaScans(reference:#{reference})")
    update_wa_scans(account, reference)
    logger.debug 'InsightAppSec WA Scans Update : OK'
  end

  private

  # Handle multiple scans update
  # @param account: InsightAppSecAccount
  # @param reference = WaScan.internal_id
  def update_wa_scans(_account, _reference = nil)
    # TODO
  end
end
