# frozen_string_literal: true

class ReportActionImport < ReportImport
  belongs_to :action_import,
    class_name: 'ActionImport',
    inverse_of: :report_action_import,
    foreign_key: :import_id,
    primary_key: :id
end
