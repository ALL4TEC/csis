# frozen_string_literal: true

module ScannersConcern
  extend ActiveSupport::Concern

  included do
    has_many :vm_scanner_accounts,
      -> { where(type: AccountPredicate::AVAILABLE_SCANNERS[:vm]) },
      through: :staff_teams,
      source: :accounts
    has_many :wa_scanner_accounts,
      -> { where(type: AccountPredicate::AVAILABLE_SCANNERS[:wa]) },
      through: :staff_teams,
      source: :accounts

    # Qualys and other analysts tools things, so no prefix needed
    has_many :qualys_configs,
      -> { qualys_configs.distinct },
      through: :staff_teams,
      source: :accounts
    has_many :qc_vm_scans, -> { distinct }, through: :qualys_configs, source: :vm_scans
    has_many :qc_wa_scans, -> { distinct }, through: :qualys_configs, source: :wa_scans
    has_many :qualys_vm_clients, -> { distinct }, through: :staff_teams
    has_many :qualys_wa_clients, -> { distinct }, through: :staff_teams
    has_many :qvc_vm_scans, through: :qualys_vm_clients, source: :vm_scans
    has_many :qwc_wa_scans, through: :qualys_wa_clients, source: :wa_scans

    has_many :cyberwatch_configs,
      -> { cyberwatch_configs.distinct },
      through: :staff_teams,
      source: :accounts
    has_many :cbw_scans, -> { distinct }, through: :cyberwatch_configs, source: :vm_scans
  end
end
