# frozen_string_literal: true

class StaffTeam < ApplicationRecord
  self.table_name = 'staffs_teams'

  belongs_to :staff,
    class_name: 'User',
    inverse_of: :staff_staffs_teams,
    primary_key: :id

  belongs_to :team,
    class_name: 'Team',
    inverse_of: :staffs_teams,
    primary_key: :id
end
