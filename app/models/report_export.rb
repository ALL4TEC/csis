# frozen_string_literal: true

class ReportExport < ApplicationRecord
  include CableReady::Broadcaster
  include EnumSelect
  has_paper_trail

  after_create do
    ReportExportRefresher.add_to_list(self)
  end

  after_update do
    ReportExportRefresher.refresh(self)
    if generated?
      receivers = report.contacts.to_a
      receivers << exporter
      BroadcastService.notify(receivers, :export_generation, versions.last)
    end
  end

  after_destroy do
    ReportExportRefresher.remove_report_export(self)
  end

  before_destroy do
    NotificationService.clear_related_to(self)
  end

  has_one_attached :document

  belongs_to :report,
    inverse_of: :exports

  belongs_to :exporter,
    class_name: 'User',
    inverse_of: :exported_exports

  enum_with_select :status, { scheduled: 0, processing: 1, generated: 2, errored: 3 }

  default_scope { order(created_at: :desc) }
end
