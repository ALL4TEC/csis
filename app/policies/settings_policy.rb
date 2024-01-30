# frozen_string_literal: true

class SettingsPolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def upload_certificates_bg?
    super_admin?
  end

  def upload_reports_logo?
    super_admin?
  end

  def upload_mails_logo?
    super_admin?
  end

  def upload_mails_webicons?
    super_admin?
  end

  def upload_wsc_thumbs?
    super_admin?
  end

  def upload_badges?
    super_admin?
  end

  def update_certs_and_stats?
    super_admin?
  end

  def reset?
    super_admin?
  end

  def customize?
    super_admin?
  end
end
