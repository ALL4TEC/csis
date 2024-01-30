# frozen_string_literal: true

class ReportTop < ApplicationRecord
  self.table_name = :reports_tops

  belongs_to :report,
    class_name: 'Report',
    inverse_of: :report_tops,
    primary_key: :id

  belongs_to :top,
    class_name: 'Top',
    inverse_of: :report_tops,
    primary_key: :id
end
