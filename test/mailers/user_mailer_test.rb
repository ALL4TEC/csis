# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'action with notification_email' do
    user = users(:c_one)

    # Create the email and store it for further assertions
    email = UserMailer.action(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([UserMailer::ACTIONS_FROM], email.from, 'Bad email from')
    assert_equal([user.notification_email], email.to, 'Bad email to')
    assert_equal(I18n.t(UserMailer::NEW_ACTIONS, locale: user.language.iso),
      email.subject, 'Bad subject')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'action without notification_email' do
    user = users(:c_two)

    # Create the email and store it for further assertions
    email = UserMailer.action(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([UserMailer::ACTIONS_FROM], email.from, 'Bad email from')
    assert_equal([user.notification_email || user.email], email.to, 'Bad email to')
    assert_equal(I18n.t(UserMailer::NEW_ACTIONS, locale: user.language.iso),
      email.subject, 'Bad subject')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'action_crypted' do
    user = users(:c_one)
    choice = []
    # Update user public key
    File.open(Gpg::TESTS_PUB_KEY) { |f| user.update(public_key: f.read) }

    # Create the email and store it for further assertions
    email = UserMailer.action_crypted(user, choice)

    # Send the email, then test that it got queued
    email.deliver_now

    # Test the body of the sent email contains what we expect it to
    assert_equal([UserMailer::ACTIONS_FROM], email.from, 'Bad email from')
    assert_equal([user.notification_email || user.email], email.to, 'Bad email to')
    assert_equal(I18n.t(UserMailer::NEW_ACTIONS, locale: user.language.iso),
      email.subject, 'Bad subject')
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'exceeding_severity_threshold_notification' do
    user = users(:staffuser)
    report = scan_reports(:mapui)

    # Create the email and store it for further assertions
    email = UserMailer.exceeding_severity_threshold_notification(user, nil, { report: report })

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_equal([user.notification_email || user.email], email.to, 'Bad email to')
    assert_equal(
      I18n.t(UserMailer::EXCEEDING_SEVERITY_THRESHOLD, locale: user.language.iso),
      email.subject, 'Bad subject'
    )
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end

  test 'exceeding_severity_threshold_notification_crypted' do
    user = users(:staffuser)
    report = scan_reports(:mapui)
    list = [wa_occurrences(:wa_occurrence_one), vm_occurrences(:vm_occurrence_one)]
    # Update user public key
    File.open(Gpg::TESTS_PUB_KEY) { |f| user.update(public_key: f.read) }

    # Create the email and store it for further assertions
    email = UserMailer.exceeding_severity_threshold_notification_crypted(
      user, nil, { report: report, occurrences: list }
    )

    # Send the email, then test that it got queued
    email.deliver_now

    # Test the body of the sent email contains what we expect it to
    assert_equal([ApplicationMailer::FROM_MAIL], email.from, 'Bad email from')
    assert_equal([user.notification_email || user.email], email.to, 'Bad email to')
    assert_equal(
      I18n.t(UserMailer::EXCEEDING_SEVERITY_THRESHOLD, locale: user.language.iso),
      email.subject, 'Bad subject'
    )
    assert_not(email.attachments.empty?, 'Logo.png should be attached')
  end
end
