# frozen_string_literal: true

module JiraConfigsHelper
  def jira_config_format_status(status)
    text = t("activerecord.attributes.jira_config_ext/status.#{status}")
    css_class = ''

    case status
    when 'expire_soon'
      css_class = 'text-warning'
    when 'ko', 'project_not_found', 'request'
      css_class = 'text-danger'
    end

    content_tag(:span, text, class: css_class)
  end
end
