# frozen_string_literal: true

require 'test_helper'

class NilClassPolicyTest < ActiveSupport::TestCase
  test 'that nil class policy scope raises exception when called' do
    assert_raise Pundit::NotDefinedError do
      NilClassPolicy::Scope.new(User.staffs.first, nil).resolve
    end
  end

  test 'that nil class policy does not display anything to anybody' do
    assert_equal false, NilClassPolicy.new(User.staffs.first, nil).show?
  end
end
