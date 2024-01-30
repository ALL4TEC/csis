# frozen_string_literal: true

module Importers
  class SellsyImporterService
    DOMAIN = '' # TODO: Customize

    def initialize(job)
      @job = job
    end

    # Import
    # @param element: 'client' or 'supplier'
    # @param account: SellsyConfig
    def import(element_name, account)
      elements_name = element_name.pluralize
      Rails.logger.debug { "importing #{elements_name}; state=start" }
      page = 1
      loop do
        Rails.logger.debug { "importing #{elements_name}; page=#{page}" }
        elements = instance_eval("Sellsy::#{element_name.capitalize}", __FILE__, __LINE__).list(
          { page: page }, account
        )
        break if elements.data.empty?

        Rails.logger.debug { "importing #{elements_name}; count=#{elements.data.length}" }
        page += 1
        elements.data.each do |elem|
          next unless elem.csis?

          contacts_emails = if elem.contacts.present?
                              import_contacts elem.contacts
                              elem.contacts.map(&:email)
                            else
                              []
                            end

          if (cli = Client.find_by(internal_type: element_name,
            ref_identifier: "SELLSY_#{elem.id}"))
            handle_update(cli, elem)
          else
            Client.create(internal_type: element_name, ref_identifier: "SELLSY_#{elem.id}",
              name: elem.name,
              web_url: elem.website_url,
              contacts: User.contacts.where(email: contacts_emails))
          end
        end
      end
      Rails.logger.debug { "importing #{elements_name}; state=finished" }
    end

    private

    def import_contacts(contacts)
      Rails.logger.debug { "importing contacts; state=start count=#{contacts.length}" }

      contacts.each do |contact|
        next unless contact.csis?

        if contact.email.empty?
          contact.email = "#{contact.first_name}.#{contact.last_name}@#{DOMAIN}"
        end
        if (con = User.contacts.find_by(email: contact.email.downcase))
          fname = "#{contact.first_name} #{contact.last_name}"
          con.full_name = fname if con.full_name != fname
          con.save! if con.changed?
        else
          User.create(
            groups: [Group.contact],
            ref_identifier: "SELLSY_#{contact.id}",
            full_name: "#{contact.first_name} #{contact.last_name}",
            email: contact.email
          )
        end
      end

      Rails.logger.debug 'importing contacts; state=finished'
    end

    # @param elem: Sellsy::#{element_name}
    # @param cli: corresponding model
    def handle_update(cli, elem)
      name = elem.name
      cli.name = name if cli.name != name
      url = elem.website_url
      cli.web_url = url if cli.web_url != url
      cs = if elem.contacts.present?
             elem.contacts.map(&:email)
           else
             []
           end
      if (cli.contacts.to_set(&:email) ^ cs).any?
        cli.contacts = User.contacts.where(email: cs) + cli.contacts.nonsellsy
      end
      cli.save! if cli.changed?
    end
  end
end
