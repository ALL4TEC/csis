# frozen_string_literal: true

# This class wraps JiraService, ServicenowService... so external ticket management can be done
# without taking care of which Service class to call for the right external ticketing tool
class TicketingService
  class << self
    def respond_to_missing?(name, include_all = false)
      methods = %i[create_ticket close_ticket update_ticket_status ticket_closable?]
      methods.include?(name) || super
    end

    # params should have at least { issue: Issue }
    def method_missing(method_name, params)
      # find service class corresponding to issue's ticketable class (JiraConfig -> JiraService)
      service_class = "#{params[:issue].ticketable.class.name.chomp('Config')}Service".constantize
      # redirect method call
      service_class.send(method_name, params)
    end
  end
end
