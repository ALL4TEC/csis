# frozen_string_literal: true

module ReportCommon
  extend ActiveSupport::Concern

  included do
    def build_app_section(new_action)
      clazz = @report.type
      reports_headers = "#{clazz}sHeaders".constantize.new
      headers = policy_headers(clazz, :member).filter
      @app_section = make_section_header(
        title: t('reports.pages.title', report: @report.title,
          date: @report.edited_at.strftime('%d/%m/%y')),
        subtitle: t('reports.pages.project', project: @report.project,
          client: @report.project.client),
        actions: reports_headers.actions([new_action] | headers[:actions], @report),
        other_actions: reports_headers.actions(headers[:other_actions] - [new_action], @report),
        scopes: reports_headers.tabs(headers[:tabs], @report),
        filter_btn: true
      )
    end
  end
end
