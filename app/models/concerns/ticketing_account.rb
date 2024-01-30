# frozen_string_literal: true

module TicketingAccount
  extend ActiveSupport::Concern

  included do
    has_many :issues,
      class_name: 'Issue',
      inverse_of: :ticketable,
      as: :ticketable,
      dependent: :destroy

    has_many :actions, through: :issues

    def account_url_prefix
      "#{ENV.fetch('ROOT_URL', nil)}/#{self.class.name.pluralize.underscore}/"
    end

    def remote_issue_url_prefix
      raise NotImplementedError, 'Implement this in models where this concern is included'
    end
  end
end
