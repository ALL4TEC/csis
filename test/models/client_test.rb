# frozen_string_literal: true

require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test 'can edit client ref_identifier' do
    client = Client.first
    client.ref_identifier = '9999'
    assert_equal '9999', client.ref_identifier
  end

  test 'ref_identifier can be present at creation' do
    client = Client.new(
      ref_identifier: '7357',
      name: 'test',
      internal_type: 'client'
    )
    assert_equal '7357', client.ref_identifier
  end
end
