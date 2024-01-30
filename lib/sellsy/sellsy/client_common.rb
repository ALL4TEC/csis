# frozen_string_literal: true

class Sellsy::ClientCommon
  attr_reader :id,
    :name,
    :website_url,
    :contacts

  # WARNING customfields for getList and customFields for getOne
  CUSTOM_FIELDS = %w[customfields customFields].freeze

  def initialize(data)
    klass = self.class.name.split('::').last
    unless data['relationType'] == klass.downcase
      raise Sellsy::Error, "The given hash does not represent a #{klass}"
    end

    @id = data['id']&.to_i
    @contacts = data['contacts']&.map { |_k, v| Sellsy::Contact.new(v) }
    @name = data['name']
    @website_url = (URI(data['web_url']) unless data['web_url'].to_s.empty?)

    CUSTOM_FIELDS.any? do |cf_key|
      @csis = data[cf_key] if data.key?(cf_key)
    end
  end
end
