# frozen_string_literal: true

class ReportWaScan < ApplicationRecord
  self.table_name = :reports_wa_scans

  belongs_to :report,
    class_name: 'Report',
    inverse_of: :report_wa_scans,
    primary_key: :id

  belongs_to :wa_scan,
    class_name: 'WaScan',
    inverse_of: :report_wa_scans,
    primary_key: :id
end
