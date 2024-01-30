# frozen_string_literal: true

class Matrix42Service
  class << self
    def create_ticket(params)
      issue = params[:issue]
      wrapper = ready_wrapper(issue.ticketable)

      # create ticket
      action = issue.action
      action_url = ENV.fetch('ROOT_URL', nil) +
                   Rails.application.routes.url_helpers.action_path(action)
      ticket_id = wrapper.create_ticket(
        action.name,
        issue.ticketable.default_ticket_type.to_sym,
        "#{I18n.t('ticketing.description')}\n#{action_url}"
      )
      # save pmt_reference and status
      issue.status = :open
      issue.pmt_reference = ticket_id
      issue.save

      # comment issue opening
      wrapper.comment(issue.pmt_reference, I18n.t('ticketing.comment.created'))
    end

    # params: { issue: Issue, resolved: Boolean }
    def close_ticket(params)
      issue = params[:issue]
      reason = params[:resolved] ? :solved : :known_error
      wrapper = ready_wrapper(issue.ticketable)
      wrapper.close_ticket(issue.pmt_reference, reason, I18n.t('ticketing.comment.closed'))
      wrapper.comment(issue.pmt_reference, I18n.t('ticketing.comment.closed'))
    end

    def update_ticket_status(params)
      issue = params[:issue]
      wrapper = ready_wrapper(issue.ticketable)
      status = wrapper.ticket_status(issue.pmt_reference)
      issue.update(status: status) unless status.to_s == issue.status
    end

    def ticket_closable?(params)
      issue = params[:issue]
      wrapper = ready_wrapper(issue.ticketable)
      wrapper.ticket_closable?(issue.pmt_reference)
    end

    private

    def ready_wrapper(matrix42_config)
      Matrix42::Wrapper.new(matrix42_config)
    end
  end
end
