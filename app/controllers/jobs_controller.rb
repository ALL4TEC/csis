# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :authenticate_user_no_redir!, only: [:detail]
  before_action :authenticate_user!, only: [:index]
  before_action :authorize!
  before_action :set_job, only: [:detail]
  before_action :set_whodunnit

  def detail
    render json: { html: render_to_string(partial: 'jobs/detail') }
  end

  def index
    @app_section = make_section_header(title: t('jobs.section_title'), filter_btn: true)
    @q_base = Job.all
    @q = @q_base.ransack params[:q]
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @jobs = @q.result.page(params[:page]).per(params[:per_page])
  end

  private

  def authorize!
    authorize(Job)
  end

  def set_job
    handle_unscoped do
      job_policy = JobPolicy::Scope.new(current_user, Job)
      @job = job_policy.resolve.find(params[:id])
    end
  end
end
