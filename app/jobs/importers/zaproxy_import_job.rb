# frozen_string_literal: true

# Job importing zaproxy wa scans
class Importers::ZaproxyImportJob < ApplicationKubeJob
  include ScanImporterCommon

  private

  def scanner_service
    Importers::ZaproxyImporterService
  end

  def kind
    :wa
  end
end
