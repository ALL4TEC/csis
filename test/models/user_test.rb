# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'devise set_reset_password_token returns the plaintext token' do
    subject = User.first
    potential_token = subject.send(:set_reset_password_token)
    potential_token_digest = Devise.token_generator.digest(
      subject, :reset_password_token, potential_token
    )
    actual_token_digest = subject.reset_password_token
    assert_equal potential_token_digest, actual_token_digest
  end

  test 'a newly created user with nothing more than email and full_name can list vm_scans' do
    user = User.create(full_name: 'John Doe', email: 'someemail@somedomain.eu')
    assert_equal([], user.vm_scans)
  end
end
