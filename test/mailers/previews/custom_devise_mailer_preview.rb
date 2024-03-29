# frozen_string_literal: true

# Preview at http://localhost:3000/rails/mailers/custom_devise_mailer
class CustomDeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    CustomDeviseMailer.confirmation_instructions(User.first, 'faketoken', {})
  end

  def unlock_instructions
    CustomDeviseMailer.unlock_instructions(User.first, 'faketoken', {})
  end

  def reset_password_instructions
    CustomDeviseMailer.reset_password_instructions(User.first, 'faketoken', {})
  end

  def send_two_factor_authentication_code
    CustomDeviseMailer.new.send_two_factor_authentication_code(User.first, 'fakecode', {})
  end
end
