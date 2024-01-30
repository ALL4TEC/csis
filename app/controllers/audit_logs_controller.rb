# frozen_string_literal: true

class AuditLogsController < ApplicationController
  include BouncerController

  def index
    common

    today = Time.zone.now
    params[:q] ||= {}
    params[:q][:start_range] ||= DateFormatter.to_ftime(2.weeks.ago)
    params[:q][:end_range] ||= DateFormatter.to_ftime(today)
    # Partition_key_in is end date exclusive so we need to call next day to be able to display
    # appropriate date on interface
    until_date = DateFormatter.to_ftime(Date.parse(params[:q][:end_range]).next_day)
    partition_key_range = [params[:q][:start_range], until_date]
    @q = PaperTrail::Version.partition_key_in(*partition_key_range)

    @q = @q.includes(:item).ransack(params[:q])
    @versions = @q.result.order(created_at: :desc).page(params[:page]).per(params[:per_page])
  end

  private

  def common
    add_home_to_breadcrumb
    title = t('audit_logs.section_title')
    add_breadcrumb title
    @app_section = make_section_header(
      title: title,
      filter_btn: true
    )
  end

  def authorize!
    authorize(PaperTrail::Version)
  end
end
