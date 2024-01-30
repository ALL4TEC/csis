# frozen_string_literal: true

# Check if element has customFields used to identify sellsy element as part of csis
module Sellsy::CsisPart
  CLIENTS = %w[Client Supplier].freeze
  attr_accessor :csis

  def self.included(base)
    # def self.get(id, account)
    base.define_singleton_method(:get) do |*args|
      klass = base.name.split('::').last
      key = klass.in?(CLIENTS) ? "#{klass.downcase}id" : 'id'
      hash = { "#{key}": args[0] }
      Sellsy::Request.do_singular(
        self, "#{klass.in?(CLIENTS) ? klass : 'Peoples'}.getOne", hash, args[1]
      )
    end
    # def self.list(params, account)
    base.define_singleton_method(:list) do |*args|
      klass = base.name.split('::').last
      defaults = {
        per_page: 50,
        page: 1
      }
      merged = defaults.merge(args[0])
      params = {
        pagination: {
          nbperpage: merged[:per_page],
          pagenum: merged[:page]
        }
      }
      Sellsy::Request.do_list(
        self, "#{klass.in?(CLIENTS) ? klass : 'Peoples'}.getList", params, args[1]
      )
    end
    # def self.client?
    # Check if instance is a client or contact
    base.define_singleton_method(:client?) do
      base.name.split('::').last.in?(CLIENTS)
    end
  end

  # Check if element contains customField with code == 'csis' and formatted_value == 'oui'
  def csis?
    # If Contact, must recall api to get more infos than provided by Client.getList.contacts
    if self.class.client?
      res = @csis
    else
      data = self.class.get(@people_id)
      initialize(data)
      res = @csis['nogroup']['list']
    end
    raise 'Bad custom fields format' unless res.is_a?(Array)

    # Here res is an array of hashes
    res.any? do |cf|
      cf['code'] == 'csis' && cf['formatted_value'] == 'oui'
    end
  end
end
