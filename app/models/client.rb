# frozen_string_literal: true

# = Client
#
# Le modèle +Client+ correspond soit à un groupe de contacts, soit à une société cliente,
# soit sous-traîtante d'un client direct.
#
# Un client est défini par son +internal_id+ (id récupéré depuis Sellsy), son nom et son
# +internal_type+ (soit +client+, soit +supplier+, également récupéré depuis Sellsy).
#
# Un client est lié à des contacts (+contacts+)
# Un client peut être lié à plusieurs projets
# Un client peut être lié à plusieurs projets en tant que sous-traîtant (+supplied_projects+)

class Client < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  has_many :client_contacts,
    class_name: 'ClientContact',
    inverse_of: :client,
    dependent: :delete_all

  has_many :contacts,
    -> { ordered_alphabetically },
    through: :client_contacts,
    source: :contact

  has_many :projects,
    class_name: 'Project',
    primary_key: :id,
    inverse_of: :client,
    dependent: :destroy

  has_many :reports, through: :projects
  has_many :actions, through: :projects

  has_many :suppliances,
    class_name: 'Suppliance',
    inverse_of: :supplier,
    foreign_key: :supplier_id,
    dependent: :delete_all

  has_many :supplied_projects,
    class_name: 'Project',
    inverse_of: :suppliers,
    foreign_key: :project_id,
    through: :suppliances

  has_many :accounts_suppliers,
    class_name: 'AccountSupplier',
    foreign_key: :supplier_id,
    inverse_of: :supplier,
    dependent: :delete_all

  has_many :accounts,
    class_name: 'Account',
    foreign_key: :account_id,
    inverse_of: :suppliers,
    through: :accounts_suppliers

  validates :name, presence: true, uniqueness: true
  validates :internal_type, presence: true

  scope :clients, -> { where(internal_type: 'client') }
  scope :suppliers, -> { where(internal_type: 'supplier') }

  # Ransack
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at discarded_at id internal_type name otp_mandatory ref_identifier updated_at
       web_url]
  end

  def to_s
    name
  end

  def users
    contacts
  end

  def group
    Group.contact
  end

  def parent_otp_mandatory?
    group.otp_mandatory?
  end

  def otp_mandatory?
    parent_otp_mandatory? || otp_mandatory
  end
end
