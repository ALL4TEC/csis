# frozen_string_literal: true

require 'styles'
require 'net/http'
require 'domainatrix'

module ApplicationHelper
  def nav_infos
    ApplicationController::NAV_INFOS[current_user.current_group_name.to_sym]
  end

  def user_path(user)
    Rails.application.routes.url_helpers.send(:"#{user.current_group_name}_path", user)
  end

  def severity_colors
    ApplicationHelper.severity_colors
  end

  def self.severity_colors
    Styles::SEVERITY_COLORS
  end

  def self.scan_type_colors
    Styles::SCAN_TYPE_COLORS
  end

  def scan_type_colors
    ApplicationHelper.scan_type_colors
  end

  def domain_name(url_str)
    url = Domainatrix.parse(url_str)
    "#{url.domain}.#{url.public_suffix}"
  end
end
