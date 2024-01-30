# frozen_string_literal: true

class Importers::SellsyImportJob < ApplicationKubeJob
  def perform(creator, account)
    job_h = {
      subscribers: [creator].compact,
      progress_steps: 1
    }
    job_h[:creator] = creator if creator.present?
    handle_perform(job_h) do |job|
      importer_service = Importers::SellsyImporterService.new(job)
      importer_service.import('client', account)
      logger.debug 'Clients import : OK'
      importer_service.import('supplier', account)
      logger.debug 'Suppliers import : OK'
      job.update!(status: :completed)
    end
  end
end
