# frozen_string_literal: true

class ReportContact < ApplicationRecord
  self.table_name = :reports_contacts

  belongs_to :report,
    class_name: 'Report',
    inverse_of: :report_contacts,
    primary_key: :id

  belongs_to :contact,
    class_name: 'User',
    inverse_of: :report_contacts,
    primary_key: :id
end
