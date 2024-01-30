# frozen_string_literal: true

class QualysWaClientTeam < ApplicationRecord
  self.table_name = 'qualys_wa_clients_teams'

  belongs_to :qualys_wa_client,
    class_name: 'QualysWaClient',
    inverse_of: :qualys_wa_clients_teams,
    primary_key: :id

  belongs_to :team,
    class_name: 'Team',
    inverse_of: :qualys_wa_clients_teams,
    primary_key: :id
end
