# frozen_string_literal: true

require 'test_helper'

class NotificationCleanerTest < ActiveSupport::TestCase
  test 'clear all' do
    # GIVEN
    # a notification older than 3 months
    # and a recent notification
    # and a notification linked to a nil version
    given
    # WHEN
    # calling Cleaners::NotificationCleaner.clear_all
    Cleaners::NotificationCleaner.clear_all
    # THEN
    # only the recent notification is kept
    assert_equal 1, Notification.all.count
    assert Notification.last.created_at > 3.months.ago
  end

  test 'clear old' do
    # GIVEN
    # a notification older than 3 months
    # and a recent notification
    given
    # WHEN
    # calling Cleaners::NotificationCleaner.clear_old
    Cleaners::NotificationCleaner.clear_old
    # THEN
    # only old notification is deleted
    assert_equal 2, Notification.all.count
    assert Notification.old.count.zero?
  end

  test 'clear linked to nil version' do
    # GIVEN
    # a notification older than 3 months
    # and a recent notification
    # and a notification linked to a nil version
    given
    # WHEN
    # calling Cleaners::NotificationCleaner.clear_linked_to_nil_version
    Cleaners::NotificationCleaner.clear_linked_to_nil_version
    # THEN
    # only the notification linked to a nil version is deleted
    assert_equal 2, Notification.all.count
    assert Notification
  end

  private

  def given
    Notification.all.destroy_all
    subject = Notification.subjects.keys.first
    # Create 3 versions
    3.times do
      PaperTrail::Version.create!(
        item_type: 'User', item_id: User.first.id, event: 'connection', whodunnit: User.first.id
      )
    end
    version_to_erase = PaperTrail::Version.first
    # linked_to_nil_version
    Notification.create!(
      version: version_to_erase, subscribers: [], subject: subject
    )
    # recent_notification
    Notification.create!(
      version: PaperTrail::Version.second, subscribers: [], subject: subject
    )
    # old_notification
    Notification.create!(
      version: PaperTrail::Version.last, subscribers: [], subject: subject,
      created_at: 4.months.ago
    )
    version_to_erase.destroy
    assert_equal 3, Notification.all.count
  end
end
