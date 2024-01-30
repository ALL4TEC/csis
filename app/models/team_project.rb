# frozen_string_literal: true

class TeamProject < ApplicationRecord
  self.table_name = :teams_projects

  belongs_to :team,
    class_name: 'Team',
    inverse_of: :teams_projects,
    primary_key: :id

  belongs_to :project,
    class_name: 'Project',
    inverse_of: :teams_projects,
    primary_key: :id
end
