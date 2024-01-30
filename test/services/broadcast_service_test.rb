# frozen_string_literal: true

require 'test_helper'

class FakeSlackWebClient
  attr_reader :calls

  def initialize
    @calls = 0
  end

  # rubocop:disable Naming/MethodName
  def chat_postMessage(_msg_payload)
    @calls += 1
  end
  # rubocop:enable Naming/MethodName
end

class BroadcastServiceTest < ActionCable::Channel::TestCase
  include ActionMailer::TestHelper

  def create_new_version(user)
    PaperTrail::Version.create!(
      item_type: 'VmScan',
      item_id: VmScan.first.id,
      event: 'create',
      whodunnit: user.id
    )
  end

  test 'Call notify on subject does send mail if configured for user' do
    # GIVEN a user with notification configured to be sent by mail for some subject
    user = User.first
    user.update(send_mail_on: Notification.subjects.keys)
    subject = Notification.subjects.keys.first
    version = create_new_version(user)
    assert_enqueued_emails(0)

    # WHEN calling notify with that subject
    BroadcastService.notify([user], subject, version)

    # THEN a mail is enqueued
    assert_enqueued_emails(1)
  end

  test 'Call notify on subject does broadcast in UsersChannel if configured for user' do
    # GIVEN a user with notification configured to be broadcasted for some subject
    user = User.first
    user.update(notify_on: Notification.subjects.keys)
    subject = Notification.subjects.keys.first
    version = create_new_version(user)
    assert_broadcasts UsersChannel.broadcasting_for(user), 0

    # WHEN calling notify with that subject
    BroadcastService.notify([user], subject, version)

    # THEN a notification is broadcasted
    assert_broadcasts UsersChannel.broadcasting_for(user), 1
  end

  test 'Call notify on subject does send mail AND broadcast if configured for user' do
    # GIVEN a user with notification configured to be broadcasted and sent by mail for some subject
    user = User.first
    user.update(
      send_mail_on: Notification.subjects.keys,
      notify_on: Notification.subjects.keys
    )
    subject = Notification.subjects.keys.first
    version = create_new_version(user)
    assert_enqueued_emails(0)
    assert_broadcasts UsersChannel.broadcasting_for(user), 0

    # WHEN calling notify with that subject
    BroadcastService.notify([user], subject, version)

    # THEN a notification is broadcasted and a mail is enqueued
    assert_enqueued_emails(1)
    assert_broadcasts UsersChannel.broadcasting_for(user), 1
  end

  test 'Call notify on subject does not send anything if not configured for user' do
    # GIVEN a user with no notification neither mail sent for all subjects
    user = User.first
    user.update(send_mail_on: [], notify_on: [])
    subject = Notification.subjects.keys.first
    version = create_new_version(user)
    assert_enqueued_emails(0)
    assert_broadcasts UsersChannel.broadcasting_for(user), 0

    # WHEN calling notify
    BroadcastService.notify([user], subject, version)

    # THEN no mail enqueued and no broadcast sent in UsersChannel for user
    assert_enqueued_emails(0)
    assert_broadcasts UsersChannel.broadcasting_for(user), 0
  end

  test 'notify a user with a slack config linked to send msg to configured channel' do
    # GIVEN a user associated with a slack config
    user = users(:staffuser)
    user.update(send_mail_on: [], notify_on: [])
    # Create 2 accounts_users
    AccountUser.create!(
      account: slack_configs(:slack_config_one),
      user_id: user.id,
      channel_id: 'SOMEID'
    )
    AccountUser.create!(
      account: slack_configs(:slack_config_two),
      user_id: user.id,
      channel_id: 'SOMEID2'
    )
    assert_equal 2, user.usable_slack_configs.count
    subject = Notification.subjects.keys.first
    version = create_new_version(user)
    fake_client = FakeSlackWebClient.new
    Slack::Web::Client.stub(:new, fake_client) do
      # WHEN calling notify
      BroadcastService.notify([user], subject, version)

      # THEN a msg is posted to all different slack configured channels
      assert_equal 2, fake_client.calls
    end
  end
end
