# frozen_string_literal: true

# Store scan imports infos:
class ScanImport < Import
  before_destroy :abort_if_used_scans

  belongs_to :scan_launch,
    class_name: 'ScanLaunch',
    inverse_of: :scan_import,
    primary_key: :id,
    optional: true

  belongs_to :account,
    class_name: 'Account',
    inverse_of: :scans_imports,
    optional: true

  has_many :wa_scans,
    class_name: 'WaScan',
    inverse_of: :scan_import,
    dependent: :destroy,
    primary_key: :id,
    foreign_key: :import_id

  has_many :vm_scans,
    class_name: 'VmScan',
    inverse_of: :scan_import,
    dependent: :destroy,
    primary_key: :id,
    foreign_key: :import_id

  has_one :report_scan_import,
    class_name: 'ReportScanImport',
    inverse_of: :scan_import,
    dependent: :destroy,
    primary_key: :id,
    foreign_key: :import_id

  has_one :report, through: :report_scan_import
  has_one :project, through: :report
  has_many :teams, through: :project

  accepts_nested_attributes_for :report_scan_import

  enum_with_select :import_type, {
    burp: 0,
    zaproxy: 1,
    nessus: 2,
    qualys: 3,
    cyberwatch: 4,
    with_secure: 5
  }, suffix: true
  # TODO: AddCyberwatch manual imports ?
  enum_with_select :import_type_without_account, { burp: 0, zaproxy: 1, nessus: 2, with_secure: 5 }

  def abort_if_used_scans
    :abort if used_scans?
  end

  def used_scans?
    !failed? && (wa_scans.any?(&:in_one_report?) || vm_scans.any?(&:in_one_report?))
  end
end
