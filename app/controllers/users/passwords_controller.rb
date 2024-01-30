# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # POST /users/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    display_ok_notice
    respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
  end

  private

  def display_ok_notice
    notice = if Devise.paranoid
               resource.errors.clear
               :send_paranoid_instructions
             else
               :send_instructions
             end
    set_flash_message! :notice, notice
  end
end
