# frozen_string_literal: true

require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'dangling notification should not cause a crash' do
    user = users(:staffuser)
    sign_in user
    # create dangling notification
    version = PaperTrail::Version.first
    notif = Notification.find_by(version: version)
    NotificationSubscription.create!(notification: notif, subscriber: user)
    version.destroy
    # try to load any page
    get '/'
    assert_response :success
  end
end
