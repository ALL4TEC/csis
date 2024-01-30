# frozen_string_literal: true

module StaffConcern
  extend ActiveSupport::Concern

  included do
    has_many :staff_staffs_teams,
      class_name: 'StaffTeam',
      foreign_key: :staff_id,
      inverse_of: :staff,
      dependent: :delete_all

    has_many :staff_teams, through: :staff_staffs_teams, source: :team
    include ScannersConcern
    has_many :team_accounts, through: :staff_teams, source: :accounts
    has_many :staff_assets, -> { distinct }, through: :team_accounts, source: :assets
    has_many :staff_targets, -> { distinct }, through: :staff_assets, source: :targets

    # Staff stuff
    has_many :staff_colleagues, -> { distinct }, through: :staff_teams, source: :staffs
    has_many :staff_projects, -> { distinct }, through: :staff_teams, source: :projects
    has_many :staff_slack_configs,
      -> { slack_configs.distinct },
      through: :staff_teams,
      source: :accounts
    has_many :staff_viewable_scheduled_scans, through: :staff_projects, source: :scheduled_scans
    has_many :staff_viewable_reports, through: :staff_projects, source: :reports
    has_many :staff_viewable_exports, through: :staff_viewable_reports, source: :exports
    # All report_imports: i.e. scan_imports + action_imports
    has_many :staff_viewable_report_imports,
      through: :staff_viewable_reports,
      source: :report_imports
    has_many :staff_viewable_scan_imports,
      through: :staff_viewable_reports,
      source: :scan_imports
    has_many :staff_viewable_action_imports,
      through: :staff_viewable_reports,
      source: :action_imports
    has_many :staff_viewable_scan_launches,
      through: :staff_viewable_reports,
      source: :scan_launches
    has_many :staff_viewable_reports_vm_scans,
      through: :staff_viewable_reports,
      source: :vm_scans
    has_many :staff_viewable_reports_wa_scans,
      through: :staff_viewable_reports,
      source: :wa_scans
    has_many :staff_projects_clients, -> { distinct }, through: :staff_projects, source: :client
    has_many :staff_projects_contacts,
      -> { distinct },
      through: :staff_projects_clients,
      source: :contacts
    # Only for staff for the moment but...
    has_many :staff_viewable_aggregates, through: :staff_viewable_reports, source: :aggregates
    has_many :staff_viewable_contents, through: :staff_viewable_aggregates, source: :contents
    has_many :staff_notes, through: :staff_viewable_reports, source: :notes

    has_many :created_reports,
      class_name: 'Report',
      inverse_of: :staff,
      foreign_key: :staff_id,
      primary_key: :id,
      dependent: :restrict_with_exception

    has_many :signed_reports,
      class_name: 'Report',
      inverse_of: :staff,
      foreign_key: :signatory_id,
      primary_key: :id,
      dependent: :nullify

    has_many :authored_actions,
      class_name: 'Action',
      inverse_of: :author,
      foreign_key: :author_id,
      primary_key: :id,
      dependent: :nullify

    has_many :exported_exports,
      class_name: 'ReportExport',
      inverse_of: :exporter,
      foreign_key: :exporter_id,
      primary_key: :id,
      dependent: :nullify

    has_many :created_scan_configurations,
      class_name: 'ScanConfiguration',
      inverse_of: :launcher,
      foreign_key: :launcher_id,
      primary_key: :id,
      dependent: :nullify

    has_many :imported_imports,
      class_name: 'Import',
      inverse_of: :importer,
      foreign_key: :importer_id,
      primary_key: :id,
      dependent: :nullify

    # Useless as from created objects but included in staff_viewable_xxx
    # has_many :scheduled_scans, through: :created_scan_configurations
    # has_many :scan_launches, through: :created_scan_configurations
    # has_many :report_imports, through: :created_reports
    # has_many :imports, through: :report_imports, source: :scan_import

    # All vm scans linked to a report viewable by user
    # + all scans linked to an account visible by user
    def vm_scans
      VmScan.union(VmScan.where(id: ScanService.visible_accounts_scans_ids(self, :vm)))
            .union(staff_viewable_reports_vm_scans)
    end

    # All wa scans linked to a report viewable by user
    # + all scans linked to an account visible by user
    def wa_scans
      WaScan.union(WaScan.where(id: ScanService.visible_accounts_scans_ids(self, :wa)))
            .union(staff_viewable_reports_wa_scans)
    end
  end
end
