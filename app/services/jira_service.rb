# frozen_string_literal: true

class JiraService
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
        description: I18n.t('ticketing.description'),
        weblink_url: action_url,
        weblink_title: I18n.t('ticketing.jira.link_name')
      )
      # save pmt_reference and status
      issue.status = :open
      issue.pmt_reference = ticket_id
      issue.save

      # comment issue opening
      wrapper.comment(issue.pmt_reference, I18n.t('ticketing.comment.created'))
    end

    def close_ticket(params)
      issue = params[:issue]
      wrapper = ready_wrapper(issue.ticketable)
      wrapper.comment(issue.pmt_reference, I18n.t('ticketing.comment.closed'))
      wrapper.close_issue(issue.pmt_reference)
    end

    def update_ticket_status(params)
      issue = params[:issue]
      wrapper = ready_wrapper(issue.ticketable)

      # if issue cannot be found, it doesn't exist/was deleted
      begin
        issue = wrapper.client.Issue.find(issue.pmt_reference)
      rescue JIRA::HTTPError
        return :not_found
      end
      # on Jira, a closed/solved issue has a 'resolution', while a todo/doing issue has not
      status = issue.resolution.nil? ? :open : :closed
      issue.update(status: status) unless status.to_s == issue.status
    end

    def ticket_closable?
      true
    end

    private

    def ready_wrapper(jira)
      throw :jira_config_unusable unless jira.status == 'ok' || jira.status == 'expire_soon'

      wrapper = Jira::Wrapper.new(jira)
      wrapper.set_auth_token
      wrapper
    end
  end
end
