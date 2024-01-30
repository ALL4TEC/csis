# frozen_string_literal: true

class ReportVmScan < ApplicationRecord
  self.table_name = :reports_vm_scans

  belongs_to :report,
    class_name: 'Report',
    inverse_of: :report_vm_scans,
    primary_key: :id

  belongs_to :vm_scan,
    class_name: 'VmScan',
    inverse_of: :report_vm_scans,
    primary_key: :id

  has_many :report_targets,
    class_name: 'ReportTarget',
    inverse_of: :report_vm_scan,
    foreign_key: :reports_vm_scans_id,
    dependent: :delete_all

  has_many :targets, through: :report_targets
end
