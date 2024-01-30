# frozen_string_literal: true

require 'test_helper'

class ActionText::RichTextPolicyTest < ActiveSupport::TestCase
  test 'that staff can see everything but contact only defined for_contact' do
    assert_equal Note.all, ActionText::RichTextPolicy::Scope.new(User.staffs.first, Note).resolve
  end

  test 'that nobody cannot do anything' do
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).index?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).show?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).new?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).create?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).edit?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).update?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).destroy?
    assert_equal false, ActionText::RichTextPolicy.new(User.staffs.first, nil).restore?
  end
end
