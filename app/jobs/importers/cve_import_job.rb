# frozen_string_literal: true

# Job importing nist cves
class Importers::CveImportJob < ApplicationKubeJob
  def perform(vulnerability_import)
    creator = vulnerability_import.importer
    job_h = {
      progress_steps: 5
    }
    if creator.present?
      job_h[:subscribers] = [creator]
      job_h[:creator] = creator
    end
    handle_perform(job_h, :update_vulnerability_import, vulnerability_import) do |job|
      job.update!(status: :init)
      logger.debug "#{self.class} started"
      Importers::CveImporterService.new(job).import_vulns(vulnerability_import)
      logger.debug "#{self.class} : OK"
      job.update!(status: :completed)
    end
  end

  def update_vulnerability_import(vulnerability_import)
    vulnerability_import.update(status: :failed)
  end
end
