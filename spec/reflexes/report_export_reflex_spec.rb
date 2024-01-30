# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportExportReflex, type: :reflex do
  fixtures :all

  describe '#destroy' do
    context 'if not authorized' do
      it 'it does not destroy and displays alert' do
        # GIVEN
        # A current contact user, unauthorized to destroy an export
        user = User.contacts.first
        export = report_exports(:report_export_one)
        reflex = build_reflex(
          url: reports_url(export.report, only_path: true),
          method_name: :destroy,
          connection: { current_user: user }
        )
        reflex.element.dataset['report-export-id'] = export.id
        # WHEN/THEN
        catch(:abort) do
          reflex.send(:authorize!)
          broadcast(prepend: { selector: ApplicationReflex::CSIS_TOAST_SEL }, broadcast: nil)
        end
      end
    end

    context 'if no report export provided' do
      it 'it does not destroy and displays alert' do
        export = report_exports(:report_export_one)
        user = export.exporter
        reflex = build_reflex(
          url: reports_url(export.report, only_path: true),
          connection: { current_user: user }
        )
        # reflex.element.dataset['report-export-id'] = export.id
        # WHEN/THEN
        catch(:abort) do
          reflex.send(:set_report_export)
          broadcast(prepend: { selector: ApplicationReflex::CSIS_TOAST_SEL }, broadcast: nil)
        end
      end
    end

    context 'if a destroyable report export provided' do
      it 'it destroys the report export and broadcast remove from list' do
        export = report_exports(:report_export_one)
        user = export.exporter
        reflex = build_reflex(
          url: reports_url(export.report, only_path: true),
          connection: { current_user: user }
        )
        reflex.element.dataset['report-export-id'] = export.id
        # WHEN/THEN
        reflex.send(:set_report_export)
        reflex.send(:destroy)
        # Info toast
        broadcast(prepend: { selector: ApplicationReflex::CSIS_TOAST_SEL }, broadcast: nil)
        broadcast(remove: { selector: export.dom_id(export) }, broadcast: export.report)
      end
    end
  end
end
