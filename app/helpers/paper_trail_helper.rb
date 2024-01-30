# frozen_string_literal: true

module PaperTrailHelper
  ACTIVITY_ACTIONS = %i[
    type display_submenu_direction totp_configuration_token encrypted_otp_secret_key
    otp_mandatory otp_activated_at
  ].freeze

  def filter_action(_data, version)
    find_version_in_array(ACTIVITY_ACTIONS, version)
  end

  def find_version_in_array(array, version)
    (array.find { |action| version.changeset.key?(action) }).presence || :unknown
  end

  def filter_activity_version(version, previous_versions)
    data = {
      date: version.created_at
    }
    case version.event
    when 'create'
      data[:event] = :creation
      data[:event_s] = t('versions.event.creation')
      data[:icon] = :add
    when 'update'
      send(filter_action(data, version), data, version, previous_versions)
    when 'destroy'
      data[:event] = :deletion
      target = t("models.#{version.item_type.underscore}")
      data[:event_s] = t('versions.event.deletion', target: target)
      data[:icon] = :delete
    else
      logger.info 'PaperTrailHelper: Version event not predicted'
    end
    data
  end

  def previous_same_event?(last_previous_version, event)
    last_previous_version.present? && last_previous_version[:event] == event
  end
end
