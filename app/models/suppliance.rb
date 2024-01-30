# frozen_string_literal: true

class Suppliance < ApplicationRecord
  self.table_name = :projects_suppliers

  belongs_to :supplied_project,
    class_name: 'Project',
    foreign_key: :project_id,
    inverse_of: :suppliances,
    primary_key: :id

  belongs_to :supplier,
    class_name: 'Client',
    inverse_of: :suppliances,
    primary_key: :id
end
