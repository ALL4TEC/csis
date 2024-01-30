# frozen_string_literal: true

module AuditLogHelper
  ITEM_TYPE_DATA = %w[
    Account Action Aggregate Certificate Client Comment Contact Dependency Exploit
    ExploitSource IdpConfig Import InsightAppSecConfig Language Note PentestReport Project
    QualysConfig QualysVmClient QualysWaClient Reference Report ReportExport ReportImport
    Role ScanImport ScanLaunch ScanReport SellsyConfig Staff Statistic Team
    Top User VmOccurrence VmScan VmTarget Vulnerability WaOccurrence WaScan
  ].freeze

  EVENTS_DATA = {
    connection: {
      icon: :connection
    },
    create: {
      icon: :add
    },
    update: {
      icon: :edit
    },
    discard: {
      icon: :delete
    },
    destroy: {
      icon: :delete
    },
    undiscard: {
      icon: :restore
    }
  }.freeze

  def event_icon(event)
    Icons::MAT[EVENTS_DATA.fetch(event.to_sym, { icon: :help })[:icon]]
  end
end
