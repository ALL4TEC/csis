# frozen_string_literal: true

class SlackApplicationsHeaders < HeadersHandler
  ACTIONS = {
    create: {
      label: 'slack_applications.actions.create',
      href: 'new_slack_application_path',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'slack_applications.actions.edit',
      href: 'edit_slack_application_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'slack_applications.actions.destroy',
      href: 'slack_application_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'slack_applications.actions.destroy_confirm'
    }
  }.freeze

  def initialize
    super({}, ACTIONS)
  end
end
