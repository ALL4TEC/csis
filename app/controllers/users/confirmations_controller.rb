# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def new
    raise Pundit::NotAuthorizedError
  end

  def create
    raise Pundit::NotAuthorizedError
  end

  # Lead to setting password form after email confirmation
  # Password creation is still optional and user can select another connexion mean
  def after_confirmation_path_for(_resource_name, resource)
    token = resource.send(:set_reset_password_token)
    edit_user_password_path(reset_password_token: token)
  end
end
