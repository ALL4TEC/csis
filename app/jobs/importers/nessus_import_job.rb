# frozen_string_literal: true

# Job importing nessus vm scans
class Importers::NessusImportJob < ApplicationKubeJob
  include ScanImporterCommon

  private

  def scanner_service
    Importers::NessusImporterService
  end
end
