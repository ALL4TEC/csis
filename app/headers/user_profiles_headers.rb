# frozen_string_literal: true

class UserProfilesHeaders < HeadersHandler
  TABS = {
    overview: {
      label: 'user_profile.actions.overview',
      href: 'profile_path',
      icon: Icons::MAT[:account_overview]
    },
    edit_password: {
      label: 'user_profile.actions.edit_password',
      href: 'edit_profile_password_path',
      icon: Icons::MAT[:account]
    },
    edit_public_key: {
      label: 'user_profile.actions.edit_public_key',
      href: 'edit_profile_public_key_path',
      icon: Icons::MAT[:key]
    },
    edit_otp: {
      label: 'user_profile.actions.edit_otp',
      href: 'edit_profile_otp_path',
      icon: Icons::MAT[:otp]
    },
    edit_display: {
      label: 'user_profile.actions.edit_display',
      href: 'edit_profile_display_path',
      icon: Icons::MAT[:display]
    },
    edit_notifications: {
      label: 'user_profile.actions.edit_notifications',
      href: 'edit_profile_notifications_path',
      icon: Icons::MAT[:notif_new]
    }
  }.freeze

  def initialize
    super(TABS, {})
  end
end
