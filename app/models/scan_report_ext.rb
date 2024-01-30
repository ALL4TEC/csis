# frozen_string_literal: true

# = ScanReportExt
#
# Le modèle ScanReportExt

class ScanReportExt < ApplicationRecord
  self.table_name = :scan_reports

  belongs_to :report,
    class_name: 'ScanReport',
    primary_key: :id,
    foreign_key: :scan_report_id,
    inverse_of: :ext
end
