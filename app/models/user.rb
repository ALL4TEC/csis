# frozen_string_literal: true

class User < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include EnumSelect
  include DeviseConcern
  include StaffConcern
  include ContactConcern
  rolify(before_add: :before_add_role)

  before_discard :deactivate_account

  attr_accessor :send_confirmation_notification

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[avatar_url confirmation_sent_at confirmed_at created_at current_sign_in_at
         current_sign_in_ip default_view direct_otp direct_otp_sent_at discarded_at
         display_submenu_direction email failed_attempts full_name id language_id last_sign_in_at
         last_sign_in_ip locked_at notification_email notify_on otp_activated_at otp_mandatory
         provider public_key ref_identifier remember_created_at reset_password_sent_at
         second_factor_attempts_count send_mail_on sign_in_count state totp_timestamp uid
         unconfirmed_email updated_at]
    end

    def from_omniauth(auth)
      if (user = find_by(email: auth.info.email, full_name: auth.info.name, state: :actif))
        user.update!(provider: auth.provider, avatar_url: auth.info.image, uid: auth.uid)
      end
      user
    end

    def from_saml(response, idp)
      attributes = response.attributes
      full_name = "#{attributes['First Name']} #{attributes['Last Name']}"

      if (user = find_by!(email: attributes['Email'])).present?
        user.update!(provider: idp, avatar_url: attributes['Avatar'], uid: response.nameid,
          full_name: full_name)
      end
      user
    end
  end

  has_many :users_groups,
    class_name: 'UserGroup',
    inverse_of: :user,
    primary_key: :id,
    dependent: :delete_all
  has_one :current_user_group,
    -> { where(current: true) },
    class_name: 'UserGroup',
    inverse_of: :user,
    primary_key: :id,
    dependent: :delete
  has_many :groups, through: :users_groups
  has_one :current_group, through: :current_user_group, source: :group

  delegate :name, to: :current_group, prefix: true, allow_nil: true

  has_many :notifications_subscriptions,
    class_name: 'NotificationSubscription',
    inverse_of: :subscriber,
    foreign_key: :subscriber_id,
    primary_key: :id,
    dependent: :destroy
  has_many :unread_notifications_subscriptions,
    -> { kept.unread.last_created_first },
    class_name: 'NotificationSubscription',
    inverse_of: :subscriber,
    foreign_key: :subscriber_id,
    primary_key: :id,
    dependent: :destroy

  has_many :subscribed_notifications, through: :notifications_subscriptions, source: :notification

  has_many :created_jobs,
    class_name: 'Job',
    inverse_of: :creator,
    foreign_key: :creator_id,
    primary_key: :id,
    dependent: :destroy

  has_many :jobs_subscriptions,
    class_name: 'JobSubscription',
    inverse_of: :subscriber,
    foreign_key: :subscriber_id,
    primary_key: :id,
    dependent: :destroy

  has_many :subscribed_jobs, through: :jobs_subscriptions, source: :job

  has_many :comments,
    class_name: 'Comment',
    inverse_of: :author,
    foreign_key: :author_id,
    primary_key: :id,
    dependent: :nullify # Keep conversations even if the author is removed

  has_many :created_accounts,
    class_name: 'Account',
    inverse_of: :creator,
    foreign_key: :creator_id,
    primary_key: :id,
    dependent: :destroy

  has_many :accounts_users,
    class_name: 'AccountUser',
    inverse_of: :user,
    dependent: :delete_all

  # TODO: Refacto as it does not correspond to all available accounts
  # TODO: Add messaging_accounts, where(type: AccountPredicate.AVAILABLE_MESSAGING_TOOLS)
  # OR add a column to store information like account category
  # among ['scanner', 'communication', 'provisioning']
  has_many :accounts, through: :accounts_users
  has_many :usable_slack_configs,
    -> { slack_configs },
    through: :accounts_users,
    source: :account
  has_many :usable_google_chat_configs,
    -> { google_chat_configs },
    through: :accounts_users,
    source: :account
  has_many :usable_microsoft_teams_configs,
    -> { microsoft_teams_configs },
    through: :accounts_users,
    source: :account
  has_many :usable_zoho_cliq_configs,
    -> { zoho_cliq_configs },
    through: :accounts_users,
    source: :account

  belongs_to :language,
    class_name: 'Language',
    inverse_of: :users,
    primary_key: :id,
    optional: true

  accepts_nested_attributes_for :accounts_users

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :notification_email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    confirmation: true,
    if: proc { |user| user.notification_email.present? }

  PASSWORD_FORMAT = /\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]]).{16,}\z/x
  validates :password, format: {
    with: PASSWORD_FORMAT, allow_blank: true, if: :password_required?
  }
  validate :pub_key_format, on: :update

  # Include devise modules.
  devise :two_factor_authenticatable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable, :lockable, :timeoutable, :zxcvbnable,
    :omniauthable, omniauth_providers: %i[google_oauth2 azure_oauth2]

  has_one_time_password(encrypted: true)

  enum_with_select :state, { inactif: 0, en_cours: 1, actif: 2 }
  enum_with_select :display_submenu_direction, { horizontal: 0, vertical: 1 }, prefix: true

  scope :staffs, -> { joins(:groups).where(groups: [Group.staff]) }
  scope :current_staffs, lambda {
    joins(:users_groups).where(users_groups: { group: Group.staff, current: true })
  }
  scope :contacts, -> { joins(:groups).where(groups: [Group.contact]) }
  scope :current_contacts, lambda {
    joins(:users_groups).where(users_groups: { group: Group.contact, current: true })
  }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :nonsellsy, -> { where.not("ref_identifier like 'SELLSY_%'") }

  scope :ordered_alphabetically, -> { order('full_name ASC, email ASC') }

  include GroupsConcern
  include OtpConcern

  # **@param:** role: Role
  # Used in case add_role is used with a symbol shared between several roles
  # (example: contact_admin)
  # which lead to adding roles linked to other group to some users...
  # Then a role is preferably passed to a user like:
  # user.roles << Role.of_<group>.find_by(name: <role_name>)
  #   # Add group corresponding to specified teams or clients
  #   # If none is specified, then no current_group
  #   # Allow before_add_role check to work as it needs groups
  #   ##### IF using the following user is created and other parameters injected after new are not
  #   ##### taken into account which can lead to unwanted behaviour for devise confirmation mails
  #   ##### for example
  #   ##### But we need to know user groups to check if role can be added
  #   # new_group = Group.staff if staff_team_ids.present?
  #   # new_group = Group.contact if contact_client_ids.present?
  #   # UserGroup.create!(user: self, group: new_group, current: true) if new_group.present?
  def before_add_role(role)
    raise 'Role not allowed as user not in group' unless role.group.in?(groups)
  end

  def deactivate_account
    inactif!
  end

  def relations
    User.union_all(
      staff_colleagues, staff_projects_contacts, contact_colleagues, contact_projects_staffs
    )
  end

  # full_name
  def to_s
    full_name
  end

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if the password
  # or confirmation are being set somewhere.
  def password_required?
    !password.nil? || !password_confirmation.nil?
  end

  def pub_key_format
    return if public_key.blank? || GPGME::Key.valid?(public_key)

    errors.add(:public_key, I18n.t('users.notices.key_fail'))
  end

  def in_dev_process?
    # email.end_with?('') # TODO: Customize
    false
  end

  # Confirmable
  def confirm!
    skip_confirmation!
    save!
  end

  # Lockable

  # zxcvbn
  def weak_words
    [full_name]
  end
end
