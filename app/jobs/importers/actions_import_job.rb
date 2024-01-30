# frozen_string_literal: true

# Job importing nist cves
class Importers::ActionsImportJob < ApplicationKubeJob
  def perform(report_action_import)
    creator = report_action_import.action_import.importer
    job_h = {
      progress_steps: 5,
      subscribers: report_action_import.report.project.staffs
    }
    job_h[:creator] = creator if creator.present?
    action_import = report_action_import.action_import
    handle_perform(job_h, :update_action_import, action_import) do |job|
      import_type = action_import.import_type
      job.update!(status: :import_actions)
      logger.debug "#{import_type} Import Job started for report: #{report_action_import.report}"
      Importers::ActionsImporterService.new(job).import_actions(report_action_import)
      logger.debug "#{import_type} import for report #{report_action_import.report}: OK"
      job.update!(status: :completed)
    end
  end

  def update_action_import(action_import)
    action_import.update(status: :failed)
  end
end
