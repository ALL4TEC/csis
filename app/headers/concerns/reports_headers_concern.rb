# frozen_string_literal: true

class ReportsHeadersConcern < HeadersHandler
  PDF_ICON = Icons::MAT[:pdf]

  def initialize
    clazzs = self.class.name.to_s.underscore.sub!('_headers', '')
    clazz = clazzs.singularize
    tabs = {
      overview: {
        label: 'scopes.overview',
        href: "#{clazz}_path(_data)",
        icon: Icons::MAT[:reports]
      },
      aggregates: {
        label: 'models.aggregates',
        href: 'report_aggregates_path(_data)',
        icon: Icons::MAT[:vulnerabilities]
      },
      action_plans: {
        label: 'models.actions',
        href: 'actions_report_path(_data)',
        icon: Icons::MAT[:actions]
      },
      exports: {
        label: 'models.exports',
        href: 'report_exports_path(_data)',
        icon: Icons::MAT[:upload]
      },
      notes: {
        label: 'models.notes',
        href: 'report_notes_path(_data)',
        icon: Icons::MAT[:notes]
      },
      scan_imports: {
        label: 'models.imports',
        href: 'report_scan_imports_path(_data)',
        icon: Icons::MAT[:download]
      },
      scan_launches: {
        label: 'models.scan_launches',
        href: 'report_scan_launches_path(_data)',
        icon: Icons::MAT[:launch]
      }
    }.freeze

    actions = {
      edit: {
        label: 'reports.actions.edit',
        href: "edit_#{clazz}_path(data)",
        icon: Icons::MAT[:edit]
      },
      create_aggregate: {
        label: 'aggregates.actions.create',
        href: 'new_report_aggregate_path(data)',
        icon: Icons::MAT[:add]
      },
      create_note: {
        label: 'notes.actions.create',
        href: 'report_new_note_path(data)',
        icon: Icons::MAT[:note_add]
      },
      export_as_pdf: {
        label: 'reports.actions.export_as_pdf',
        href: 'report_exports_path(data, format: :pdf)',
        method: :post,
        icon: PDF_ICON
      },
      export_as_xlsx: {
        label: 'reports.actions.export_as_xlsx',
        href: 'report_exports_path(data, format: :xlsx)',
        method: :post,
        logo: Icons::LOGOS[:excel]
      },
      import_scan: {
        label: 'reports.actions.import_scan',
        href: 'new_report_scan_import_path(data)',
        icon: Icons::MAT[:download]
      },
      launch_scan: {
        label: 'reports.actions.launch_scan',
        href: 'new_report_scan_launch_path(data)',
        icon: Icons::MAT[:launch]
      },
      export_no_arch: {
        label: 'exports.actions.no_architecture',
        href: 'report_exports_path(data, archi: false)',
        method: :post,
        icon: PDF_ICON
      },
      export_no_histo: {
        label: 'exports.actions.no_history',
        href: 'report_exports_path(data, histo: false)',
        method: :post,
        icon: PDF_ICON
      },
      regenerate_scoring: {
        label: 'projects.labels.scoring',
        href: 'regenerate_scoring_report_path(data)',
        method: :put,
        icon: Icons::MAT[:scoring]
      },
      destroy: {
        label: 'reports.actions.destroy',
        href: 'report_path(data)',
        method: :delete,
        icon: Icons::MAT[:delete],
        confirm: 'reports.actions.destroy_confirm'
      },
      auto_aggregate: {
        label: 'reports.actions.auto_aggregate',
        href: 'auto_aggregate_report_path(data, mixing: true)',
        method: :post,
        icon: Icons::MAT[:auto_aggregate]
      },
      auto_aggregate_no_mixing: {
        label: 'reports.actions.auto_aggregate_no_mixing',
        href: 'auto_aggregate_report_path(data, mixing: false)',
        method: :post,
        icon: Icons::MAT[:auto_aggregate]
      }
    }.freeze
    super(tabs, actions)
  end
end
