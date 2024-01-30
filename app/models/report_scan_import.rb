# frozen_string_literal: true

class ReportScanImport < ReportImport
  belongs_to :scan_import,
    class_name: 'ScanImport',
    inverse_of: :report_scan_import,
    foreign_key: :import_id,
    primary_key: :id

  validates :scan_name, presence: true
  validates :auto_aggregate, inclusion: { in: [true, false] }
  validates :auto_aggregate_mixing, inclusion: { in: [true, false] }
end
