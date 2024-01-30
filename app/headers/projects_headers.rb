# frozen_string_literal: true

class ProjectsHeaders < HeadersHandler
  TABS = {
    all: {
      subtitle: 'projects.scopes.all.subtitle',
      label: 'scopes.all',
      href: 'projects_path',
      badge: '_data.kept.count',
      icon: Icons::MAT[:dashboard]
    },
    trashed: {
      subtitle: 'projects.scopes.trashed.subtitle',
      label: 'scopes.trashed',
      href: 'trashed_projects_path',
      badge: '_data.trashed.count',
      icon: Icons::MAT[:delete]
    },
    overview: {
      label: 'scopes.overview',
      href: 'project_path(_data)',
      icon: Icons::MAT[:dashboard]
    },
    reports: {
      label: 'models.reports',
      href: 'project_reports_path(_data)',
      icon: Icons::MAT[:reports],
      badge: '_data.reports.count'
    },
    statistics: {
      label: 'models.statistics',
      href: 'project_statistics_path(_data)',
      icon: Icons::MAT[:statistics]
    },
    scheduled_scans: {
      label: 'models.scheduled_scans',
      href: 'project_scheduled_scans_path(_data)',
      icon: Icons::MAT[:schedule],
      badge: '_data.scheduled_scans.count'
    }
  }.freeze

  ACTIONS = {
    new: {
      label: 'projects.actions.create',
      href: 'new_project_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'projects.actions.edit',
      href: 'edit_project_path(data)',
      icon: Icons::MAT[:edit]
    },
    create_scan_report: {
      label: 'projects.actions.create_scan_report',
      href: 'new_project_scan_report_path(data)',
      icon: Icons::MAT[:add]
    },
    create_pentest_report: {
      label: 'projects.actions.create_pentest_report',
      href: 'new_project_pentest_report_path(data)',
      icon: Icons::MAT[:add]
    },
    create_action_plan_report: {
      label: 'projects.actions.create_action_plan_report',
      href: 'new_project_action_plan_report_path(data)',
      icon: Icons::MAT[:add]
    },
    regenerate_scoring: {
      label: 'projects.labels.scoring',
      href: 'regenerate_scoring_project_path(data)',
      method: :put,
      icon: Icons::MAT[:scoring]
    },
    regenerate_all_scoring: {
      label: 'projects.labels.scoring',
      href: 'regenerate_all_scoring_projects_path',
      method: :put,
      icon: Icons::MAT[:scoring]
    },
    destroy: {
      label: 'projects.actions.destroy',
      href: 'project_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'projects.actions.destroy_confirm'
    },
    schedule_scan: {
      label: 'projects.actions.schedule_scan',
      href: 'new_project_scheduled_scan_path(data)',
      icon: Icons::MAT[:schedule]
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
