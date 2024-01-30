# frozen_string_literal: true

# Store imports infos:
class Import < ApplicationRecord
  include EnumSelect
  has_paper_trail

  belongs_to :importer,
    class_name: 'User',
    inverse_of: :imported_imports,
    optional: true

  enum_with_select :status, { scheduled: 0, processing: 1, completed: 2, failed: 3 }

  default_scope { order(created_at: :desc) }

  # Type de l'outil dont on importe l'output. Ex: Burp
  validates :import_type, presence: true
end
