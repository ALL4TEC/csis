# frozen_string_literal: true

class Team < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  default_scope -> { kept }
  has_many :accounts_teams,
    class_name: 'AccountTeam',
    inverse_of: :team,
    dependent: :delete_all

  has_many :accounts, through: :accounts_teams

  has_many :staffs_teams,
    class_name: 'StaffTeam',
    inverse_of: :team,
    dependent: :delete_all

  has_many :staffs,
    -> { ordered_alphabetically },
    through: :staffs_teams,
    source: :staff

  has_many :teams_projects,
    class_name: 'TeamProject',
    primary_key: :id,
    inverse_of: :team,
    dependent: :delete_all

  has_many :projects, through: :teams_projects

  has_many :qualys_vm_clients_teams,
    class_name: 'QualysVmClientTeam',
    inverse_of: :team,
    dependent: :delete_all

  has_many :qualys_vm_clients, through: :qualys_vm_clients_teams

  has_many :qualys_wa_clients_teams,
    class_name: 'QualysWaClientTeam',
    inverse_of: :team,
    dependent: :delete_all

  has_many :qualys_wa_clients, through: :qualys_wa_clients_teams

  validates :name, presence: true

  # Ransack
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at discarded_at id name otp_mandatory updated_at]
  end

  def to_s
    name
  end

  def users
    staffs
  end

  def group
    Group.staff
  end

  def parent_otp_mandatory?
    group.otp_mandatory?
  end

  def otp_mandatory?
    parent_otp_mandatory? || otp_mandatory
  end
end
