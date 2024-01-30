# frozen_string_literal: true

# Job importing burp wa scans
class Importers::BurpIssuesImportJob < ApplicationKubeJob
  include ScanImporterCommon

  private

  def scanner_service
    Importers::BurpImporterService
  end
end
