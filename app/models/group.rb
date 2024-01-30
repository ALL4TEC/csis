# frozen_string_literal: true

class Group < ApplicationRecord
  GROUP_TEAM_KIND = {
    staff: Team,
    contact: Client
  }.freeze

  USER_TEAMS = {
    staff: :staff_teams,
    contact: :contact_clients
  }.freeze

  has_many :users_groups,
    class_name: 'UserGroup',
    inverse_of: :group,
    primary_key: :id,
    dependent: :delete_all

  has_many :users, through: :users_groups

  has_many :roles,
    class_name: 'Role',
    inverse_of: :group,
    primary_key: :id,
    dependent: :delete_all

  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end

  def self.staff
    Group.find_by(name: 'staff')
  end

  def self.contact
    Group.find_by(name: 'contact')
  end

  def self.team_kind(name)
    GROUP_TEAM_KIND[name.to_sym]
  end

  def team_kind
    GROUP_TEAM_KIND[name.to_sym]
  end

  def parent_otp_mandatory?
    false
  end

  def otp_mandatory?
    otp_mandatory
  end
end
