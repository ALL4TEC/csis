# frozen_string_literal: true

require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  test 'cloture action if state is reviewed_fix' do
    action = actions(:action_one)
    assert_equal('to_fix', action.state, 'bad state')
    assert_equal('active', action.meta_state, 'bad meta_state')
    action.state = 7
    action.update_meta
    assert_equal('clotured', action.meta_state, 'update did not work')
  end

  test 'cloture action if state is accepted_risk_not_fixed' do
    action = actions(:action_one)
    assert_equal('to_fix', action.state, 'bad state')
    assert_equal('active', action.meta_state, 'bad meta_state')
    action.state = 5
    action.update_meta
    assert_equal('clotured', action.meta_state, 'update did not work')
  end

  test 'update action state triggers notification' do
    action = actions(:action_one)
    assert_equal('to_fix', action.state, 'bad state')
    assert_equal('active', action.meta_state, 'bad meta_state')
    mocked_method = Minitest::Mock.new
    mocked_method.expect :call, nil, [Array, :action_state_update, PaperTrail::Version]
    BroadcastService.stub :notify, mocked_method do
      action.update(state: 6)
    end
    mocked_method.verify
  end
end
