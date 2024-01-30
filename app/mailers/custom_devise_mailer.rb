# frozen_string_literal: true

# Override default methods to add gpg signature
class CustomDeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  # If there is an object in your application that returns a contact email, you can use it as
  # follows
  # Note that Devise passes a Devise::Mailer object to your proc, hence the parameter throwaway(*)
  default from: ApplicationMailer::FROM_MAIL
  self.delivery_job = MailDeliveryJob

  def confirmation_instructions(record, token, _opts = {})
    super(record, token, gpg: { sign: true })
  end

  def reset_password_instructions(record, token, _opts = {})
    super(record, token, gpg: { sign: true })
  end

  def unlock_instructions(record, token, _opts = {})
    super(record, token, gpg: { sign: true })
  end

  def email_changed(record, _opts = {})
    super(record, gpg: { sign: true })
  end

  def password_change(record, _opts = {})
    super(record, gpg: { sign: true })
  end

  def send_two_factor_authentication_code(record, code, _opts = {})
    add_inline_attachments!
    @code = code
    devise_mail(record, :send_two_factor_authentication_code, gpg: { sign: true })
  end
end
