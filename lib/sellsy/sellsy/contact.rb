# frozen_string_literal: true

class Sellsy::Contact
  include Sellsy::CsisPart

  attr_reader :last_name,
    :first_name,
    :email,
    :id,
    :people_id,
    :full_name

  # WARNING customfields for getList and customFields for getOne
  CUSTOM_FIELDS = %w[customfields customFields].freeze

  def initialize(data)
    @last_name = data['name']
    @first_name = data['forename']
    @email = data['email']
    @id = data['id']&.to_i
    @people_id = data['peopleid']&.to_i
    @full_name = data['fullName']

    CUSTOM_FIELDS.any? do |cf_key|
      @csis = data[cf_key] if data.key?(cf_key)
    end
  end
end
