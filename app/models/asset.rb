# frozen_string_literal: true

class Asset < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model
  include EnumSelect

  validates :name, presence: true
  validates :category, presence: true
  validates :confidentiality, presence: true
  validates :integrity, presence: true
  validates :availability, presence: true

  enum_with_select :category, {
    no_category: 0,
    server: 1,
    desktop: 2,
    hypervisor: 3,
    network_device: 4,
    network_target_or_website: 5,
    docker_image: 6
  }
  enum_with_select :confidentiality, {
    confidentiality_requirement_low: 0,
    confidentiality_requirement_medium: 1,
    confidentiality_requirement_high: 2
  }
  enum_with_select :integrity, {
    integrity_requirement_low: 0,
    integrity_requirement_medium: 1,
    integrity_requirement_high: 2
  }
  enum_with_select :availability, {
    availability_requirement_low: 0,
    availability_requirement_medium: 1,
    availability_requirement_high: 2
  }

  belongs_to :account,
    class_name: 'Account',
    primary_key: :id,
    inverse_of: :assets

  belongs_to :asset_import,
    class_name: 'AssetImport',
    primary_key: :id,
    foreign_key: :import_id,
    inverse_of: :assets,
    optional: true

  has_many :assets_targets,
    class_name: 'AssetTarget',
    primary_key: :id,
    inverse_of: :asset,
    dependent: :delete_all

  has_many :targets, through: :assets_targets
  has_many :vm_scans, through: :targets
  has_many :wa_scans, through: :targets

  has_many :assets_projects,
    class_name: 'AssetProject',
    primary_key: :id,
    inverse_of: :asset,
    dependent: :delete_all

  has_many :projects, through: :assets_projects

  # Récupère la date de la dernière analyse par un scanner
  def analyzed_at(account_id)
    vm = vm_scans.where(account_id: account_id).order(launched_at: :desc).first&.launched_at
    wa = wa_scans.where(account_id: account_id).order(launched_at: :desc).first&.launched_at
    if wa.present? && vm.present?
      [vm, wa].min
    else
      vm || wa
    end
  end

  # Compare new_date with previously stored analyzed_at date
  def newly_analyzed?(account_id, new_date)
    previous_date = analyzed_at(account_id)
    return true if previous_date.nil?

    previous_date < new_date
  end

  def confidentiality_short
    shorten(confidentiality)
  end

  def integrity_short
    shorten(integrity)
  end

  def availability_short
    shorten(availability)
  end

  def to_s
    name
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[account_id availability category confidentiality created_at description discarded_at id
       import_id integrity name os updated_at]
  end

  private

  def shorten(string)
    string.split('_').last
  end
end
