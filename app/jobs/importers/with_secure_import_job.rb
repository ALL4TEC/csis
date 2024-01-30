# frozen_string_literal: true

# Job importing nessus vm scans
class Importers::WithSecureImportJob < ApplicationKubeJob
  include ScanImporterCommon

  private

  def scanner_service
    Importers::WithSecureImporterService
  end
end
