# frozen_string_literal: true

module PaperTrailActivityHelper
  # rubocop:disable Lint/UselessAssignment
  def otp_mandatory(data, version, previous_versions)
    data[:icon] = :otp
    if version.changeset[:otp_mandatory][0] == true
      data[:event] = :unforce_otp_mandatory
      if previous_same_event?(previous_versions.last, data[:event])
        data = nil
      else
        data[:event_s] = t('versions.event.no_otp_mandatory_html', infos: version.item.to_s)
      end
    else
      data[:event] = :force_otp_mandatory
      if previous_same_event?(previous_versions.last, data[:event])
        data = nil
      else
        data[:event_s] = t('versions.event.otp_mandatory_html', infos: version.item.to_s)
      end
    end
  end

  def otp_activated_at(data, version, _previous_versions)
    data[:icon] = :otp
    if version.changeset[:otp_activated_at][1].present?
      data[:event] = :activate_otp
      data[:event_s] = t('versions.event.otp_activated')
    else
      data[:event] = :deactivate_otp
      data[:event_s] = t('versions.event.otp_deactivated')
    end
  end

  def type(data, version, _previous_versions)
    data[:icon] = :switch
    data[:event] = :switch_view
    data[:event_s] = t('versions.event.switch_view_html', view: version.changeset[:type][1])
  end

  def display_submenu_direction(data, version, _previous_versions)
    data[:icon] = :display
    data[:event] = :display_submenu_direction
    direction = version.changeset[:display_submenu_direction][1]
    data[:event_s] = t('versions.event.display_submenu_direction_html', direction: direction)
  end

  def totp_configuration_token(data, version, _previous_versions)
    data[:icon] = :otp
    if version.changeset[:totp_configuration_token][1].nil?
      data[:event] = :totp_configuration_validation
      data[:event_s] = t('versions.event.totp_configuration_validation')
    elsif version.changeset[:totp_configuration_token][0].nil?
      data[:event] = :new_totp_configuration
      data[:event_s] = t('versions.event.new_totp_configuration')
    end
  end

  def encrypted_otp_secret_key(data, version, _previous_versions)
    data[:icon] = :otp
    if version.changeset[:encrypted_otp_secret_key][1].nil?
      data[:event] = :clear_totp
      data[:event_s] = t('versions.event.clear_totp')
    else
      data[:event] = :new_totp_configuration
      data[:event_s] = t('versions.event.new_totp_configuration')
    end
  end

  def unknown(data, version, _previous_version)
    condition = Rails.application.config.display_unknown_versions && current_user.in_dev_process?
    return unless condition

    data[:event] = :unknown
    data[:event_s] = "Modification de : #{version.item} | #{version.changeset}"
  end
  # rubocop:enable Lint/UselessAssignment
end
