# frozen_string_literal: true

# = VmOccurrence
#
# Le modèle +VmOccurrence+ représente le résultat d'un scan concernant une destination précise.
#
# Dans le cas des Vulnerability Management (Vm) :
#
# Le +VmOccurrence+ est lié à une vulnérabilité, la vulnérabilité correspondant au résultat.
# Le +VmOccurrence+ est lié à un seul +Target+, une seule destination
# Un +VmOccurrence+ contient nécessairement un résultat : données resultantes du scan.

class VmOccurrence < Occurrence
  include KindConcern

  has_paper_trail

  before_create do
    fqdn_ip if fqdn.present? && ip.blank?
  end

  after_create do
    create_target if ip.present?
  end

  has_many :aggregate_vm_occurrences,
    class_name: 'AggregateVmOccurrence',
    inverse_of: :vm_occurrence,
    dependent: :delete_all

  has_many :aggregates,
    class_name: 'Aggregate',
    foreign_key: :aggregate_id,
    inverse_of: :vm_occurrences,
    through: :aggregate_vm_occurrences

  belongs_to :vulnerability,
    class_name: 'Vulnerability',
    primary_key: :id,
    inverse_of: :vm_occurrences

  belongs_to :scan,
    class_name: 'VmScan',
    primary_key: :id,
    inverse_of: :occurrences

  attr_readonly :netbios, :fqdn

  def real_target
    ip
  end

  # linked scan target
  def target
    scan.targets.where(ip: ip)&.first
  end

  private

  def fqdn_ip
    self.ip = IPSocket.getaddress(fqdn)
  rescue SocketError
    Rails.logger.debug('Could not get address from fqdn')
  end

  def create_target
    target = Target.find_or_create_by!(kind: 'VmTarget', name: ip.to_s, ip: ip)
    return if target.id.in?(scan.target_ids)

    TargetScan.create!(target: target, scan: scan, scan_type: 'VmScan')
  end
end
