# frozen_string_literal: true

module PunditController
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    helper_method :contact_signed_in?, :staff_signed_in?
  end

  protected

  def authenticate_user_no_redir!
    return if user_signed_in?

    render json: { error: render_to_string(partial: 'layouts/unauthorized') },
      status: :unauthorized
  end

  def staff_signed_in?
    user_signed_in? && current_user.staff?
  end

  def contact_signed_in?
    user_signed_in? && current_user.contact?
  end
end
