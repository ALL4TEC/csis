# frozen_string_literal: true

class QualysVmClient < QualysClient
  has_many :vm_scans,
    class_name: 'VmScan',
    inverse_of: :qualys_vm_client,
    primary_key: :id,
    dependent: :nullify

  belongs_to :qualys_config,
    class_name: 'QualysConfig',
    primary_key: :id,
    inverse_of: :qualys_vm_clients

  has_many :qualys_vm_clients_teams,
    class_name: 'QualysVmClientTeam',
    primary_key: :id,
    inverse_of: :qualys_vm_client,
    dependent: :delete_all

  has_many :teams, through: :qualys_vm_clients_teams

  validates :qualys_id, presence: true
  validates :qualys_name, presence: true

  scope :without_team, -> { where.not(id: QualysVmClientTeam.select(:qualys_vm_client_id)) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id qualys_config_id qualys_id qualys_name updated_at]
  end

  def to_s
    qualys_name
  end

  def scans
    vm_scans
  end
end
