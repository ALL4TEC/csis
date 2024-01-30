# frozen_string_literal: true

# Available roles and corresponding priority:
# of_staffs
#   super_admin - 0
#   cyber_admin - 1
#   contact_admin - 2
#   cyber_analyst: default - nil
# of_contacts
#   contact_admin - 1
#   contact_manager - 2
#   contact: default - nil

class Role < ApplicationRecord
  include EnumSelect
  has_paper_trail

  has_many :users_roles,
    class_name: 'UserRole',
    inverse_of: :role,
    dependent: :delete_all

  has_many :users, through: :users_roles

  belongs_to :group,
    class_name: 'Group',
    inverse_of: :roles,
    primary_key: :id

  belongs_to :resource,
    polymorphic: true,
    optional: true

  validates :resource_type,
    inclusion: { in: Rolify.resource_types },
    allow_nil: true

  scope :allowing_self_edit, -> { where('priority < 2') }
  scope :prioritized, -> { order(priority: :asc) }
  scope :without_super, -> { where.not(name: :super_admin) }

  scopify

  scope :of_staffs, -> { where(group_id: Group.staff.id) }
  scope :of_contacts, -> { where(group_id: Group.contact.id) }

  def parent_otp_mandatory?
    group.otp_mandatory?
  end

  def otp_mandatory?
    parent_otp_mandatory? || otp_mandatory
  end

  def to_s
    I18n.t("role.#{name}")
  end
end
