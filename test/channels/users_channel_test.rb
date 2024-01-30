# frozen_string_literal: true

require 'test_helper'

class UsersChannelTest < ActionCable::Channel::TestCase
  test 'subscription & unsub' do
    UsersChannel.any_instance.stubs(:current_user).returns(users(:staffuser))
    subscribe

    assert subscription.confirmed?

    unsubscribe

    assert subscription.confirmed?
  end
end
