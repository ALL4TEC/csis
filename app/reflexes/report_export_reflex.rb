# frozen_string_literal: true

class ReportExportReflex < ApplicationReflex
  before_reflex :authorize!
  before_reflex :set_whodunnit
  before_reflex :set_report_export, only: %i[destroy]

  def destroy
    @export.destroy
    toast(:info, I18n.t('exports.notices.deleted'))
  end

  private

  def authorize!
    handle_unauthorized { authorize(ReportExport) }
  end

  def set_report_export
    report_export_id = element.dataset['report-export-id']
    handle_unscoped { @export = policy_scope(ReportExport).find(report_export_id) }
  end
end
