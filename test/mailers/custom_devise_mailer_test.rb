# frozen_string_literal: true

require 'test_helper'

class CustomDeviseMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def setup
    host = 'www.example.com'
    default_url_options[:host] = host
  end

  test 'send reset_password_instructions later' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = CustomDeviseMailer.reset_password_instructions(user, 'token')

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_later
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'send confirmation_instructions later' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = CustomDeviseMailer.confirmation_instructions(user, 'token')

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_later
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'send unlock_instructions later' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = CustomDeviseMailer.unlock_instructions(user, 'token')

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_later
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'send send_two_factor_authentication_code later' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = CustomDeviseMailer.send_two_factor_authentication_code(user, 'code')

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_later
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'send email_changed later' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = CustomDeviseMailer.email_changed(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_later
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'send password_change later' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = CustomDeviseMailer.password_change(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_later
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  # #478
  test 'that devise sends mails later' do
    user = users(:c_one)
    assert_enqueued_emails 1 do
      user.send(:send_devise_notification, :email_changed)
    end
  end
end
