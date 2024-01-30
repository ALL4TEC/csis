# frozen_string_literal: true

# Store scan imports infos:
class ActionImport < Import
  has_many :imported_actions,
    class_name: 'Action',
    inverse_of: :action_import,
    dependent: :destroy,
    primary_key: :id,
    foreign_key: :import_id

  has_one :report_action_import,
    class_name: 'ReportActionImport',
    inverse_of: :action_import,
    dependent: :destroy,
    primary_key: :id,
    foreign_key: :import_id

  has_one :report, through: :report_action_import
  has_one :project, through: :report
  has_many :teams, through: :project

  accepts_nested_attributes_for :report_action_import

  enum_with_select :import_type, {
    csv: 0
  }, suffix: true
end
