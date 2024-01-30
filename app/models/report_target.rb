# frozen_string_literal: true

class ReportTarget < ApplicationRecord
  self.table_name = :reports_targets

  belongs_to :report_vm_scan,
    class_name: 'ReportVmScan',
    foreign_key: :reports_vm_scans_id,
    inverse_of: :report_targets,
    primary_key: :id

  belongs_to :target,
    class_name: 'Target',
    inverse_of: :report_targets,
    primary_key: :id
end
