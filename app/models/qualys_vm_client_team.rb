# frozen_string_literal: true

class QualysVmClientTeam < ApplicationRecord
  self.table_name = 'qualys_vm_clients_teams'

  belongs_to :qualys_vm_client,
    class_name: 'QualysVmClient',
    inverse_of: :qualys_vm_clients_teams,
    primary_key: :id

  belongs_to :team,
    class_name: 'Team',
    inverse_of: :qualys_vm_clients_teams,
    primary_key: :id
end
