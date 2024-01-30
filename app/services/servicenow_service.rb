# frozen_string_literal: true

class ServicenowService
  class << self
    def create_ticket(params)
      issue = params[:issue]
      wrapper = ready_wrapper(issue.ticketable)

      # create ticket
      action = issue.action
      action_url = ENV.fetch('ROOT_URL', nil) +
                   Rails.application.routes.url_helpers.action_path(action)
      ticket_id = wrapper.create_issue(
        action.name,
        description: "#{I18n.t('ticketing.description')}\n#{action_url}" # TODO
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
      close_code = params[:resolved] ? issue.ticketable.fixed_vuln : issue.ticketable.accepted_risk
      wrapper = ready_wrapper(issue.ticketable)
      wrapper.comment(issue.pmt_reference, I18n.t('ticketing.comment.closed'))
      wrapper.close_issue(issue.pmt_reference, close_code)
    end

    def update_ticket_status(params)
      issue = params[:issue]
      status = fetch_ticket_status(issue)
      issue.update(status: status) unless status.to_s == issue.status
    end

    def ticket_closable?
      true
    end

    private

    def fetch_ticket_status(issue)
      wrapper = ready_wrapper(issue.ticketable)
      wrapper.issue_status(issue.pmt_reference)
    rescue Servicenow::Error
      :closed
    end

    def ready_wrapper(servicenow_config)
      throw :servicenow_config_unusable unless servicenow_config.status == 'ok'

      Servicenow::Wrapper.new(servicenow_config)
    end
  end
end
