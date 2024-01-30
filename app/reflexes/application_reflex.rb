# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  include Pundit::Authorization
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  delegate :current_user, to: :connection

  CSIS_TOAST_SEL = '#csis-toasts'

  def handle_unauthorized
    yield
  rescue Pundit::NotAuthorizedError
    toast(:alert, I18n.t('actions.notices.no_rights'))
    throw :abort
  end

  # Rescue ActiveRecord::RecordNotFound to redirect not authorized users !
  def handle_unscoped
    yield
  rescue ActiveRecord::RecordNotFound
    toast(:alert, I18n.t('activerecord.errors.not_found'))
    throw :abort
  end

  def toast(type, message)
    cable_ready.prepend(
      selector: CSIS_TOAST_SEL,
      html: render(Toast::Component.new(toast_type: type).with_content(message), layout: false)
    ).broadcast
  end

  def set_whodunnit
    PaperTrail.request.whodunnit = current_user.id
  end
end
