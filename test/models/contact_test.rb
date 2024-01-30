# frozen_string_literal: true

require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test 'can edit ref_identifier' do
    contact = User.contacts.first
    contact.ref_identifier = '9999'
    assert_equal '9999', contact.ref_identifier
  end

  test 'ref_identifier can be present at creation' do
    contact = User.contacts.new(
      ref_identifier: 7357,
      full_name: 'test',
      email: 'test@test.test'
    )
    assert_equal '7357', contact.ref_identifier
  end
end
