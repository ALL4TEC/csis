# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[destroy]
  before_action :set_whodunnit
  before_action :set_issue, only: %i[destroy]
  before_action :set_action
  before_action :authorize_issue!, only: %i[destroy]

  # post '/actions/:action_id/issues/'
  def create
    @issue = Issue.create(action: @action, ticketable: Account.find(issue_params[:ticketable_id]))
    if @issue.save
      begin
        TicketingService.create_ticket(issue: @issue)
      rescue Matrix42::Error
        @issue.destroy
        flash[:alert] = t('issues.notices.creation_failure')
      end
    else
      flash[:alert] = t('issues.notices.creation_failure')
    end
    redirect_to action_path(@action)
  end

  # delete '/actions/:action_id/issues/:id'
  def destroy
    TicketingService.close_ticket(issue: @issue, resolved: issue_params[:resolved] == 'true')
    @issue.update(status: :closed)
  rescue Matrix42::Error
    flash[:alert] = t('issues.notices.deletion_failure')
  ensure
    # Redirection necessary even if no exception is thrown to ensure the page is reloaded;
    # if not redirected, page is displayed from cache and the issue appears still open
    redirect_to action_path(@action)
  end

  private

  def authorize!
    authorize(Issue)
  end

  def authorize_issue!
    authorize(@issue)
  end

  def set_issue
    id = params[:id]
    handle_unscoped { @issue = policy_scope(Issue).find(id) }
  end

  def set_action
    id = params[:action_id]
    handle_unscoped { @action = policy_scope(Action).find(id) }
  end

  def issue_params
    params.permit(policy(Issue).permitted_attributes)
  end
end
