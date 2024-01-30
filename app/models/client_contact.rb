# frozen_string_literal: true

class ClientContact < ApplicationRecord
  self.table_name = :clients_contacts

  belongs_to :client,
    class_name: 'Client',
    inverse_of: :client_contacts,
    primary_key: :id

  belongs_to :contact,
    class_name: 'User',
    inverse_of: :contact_client_contacts,
    primary_key: :id
end
