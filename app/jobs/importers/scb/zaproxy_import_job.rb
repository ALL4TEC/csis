# frozen_string_literal: true

# Job importing zaproxy wa scans
module Importers
  module Scb
    class ZaproxyImportJob < ApplicationKubeJob
      include ScanImporterCommon

      private

      def scanner_service
        Importers::Scb::ZaproxyImporterService
      end
    end
  end
end
