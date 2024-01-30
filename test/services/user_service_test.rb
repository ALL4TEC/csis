# frozen_string_literal: true

require 'test_helper'

class UserServiceTest < ActiveJob::TestCase
  test 'that a user is created with specified parameters' do
    # GIVEN specified data
    info = {
      email: 'test@something.com',
      full_name: 'Test',
      password: 'AtLeast16Chars!?'
    }
    groups = [Group.staff, Group.contact]
    roles = %i[super_admin cyber_admin contact_admin]
    # WHEN calling UserService.add()
    UserService.add(info, groups, roles)
    # THEN a user is created corresponding to passed arguments
    created_user = User.find_by(email: info[:email])
    assert created_user.present?
    check_user_info(created_user, info)
    check_groups(created_user, groups)
    check_roles(created_user, roles)
  end

  test 'that we can create a user and bypass email confirmation' do
    # GIVEN specified data
    info = {
      email: 'test@something.com',
      full_name: 'Test',
      password: 'AtLeast16Chars!?',
      confirm: true
    }
    groups = [Group.staff, Group.contact]
    roles = %i[super_admin cyber_admin contact_admin]
    # WHEN calling UserService.add()
    UserService.add(info, groups, roles)
    # THEN a user is created corresponding to passed arguments
    created_user = User.find_by(email: info[:email])
    assert created_user.present?
    check_user_info(created_user, info)
    check_groups(created_user, groups)
    check_roles(created_user, roles)
  end

  test 'that an init user is created with specified parameters' do
    # GIVEN specified data
    info = {
      email: 'test@something.com',
      full_name: 'Test',
      password: 'AtLeast16Chars!?'
    }
    groups = [Group.staff]
    roles = [:super_admin]
    # WHEN calling UserService.add()
    UserService.add_user_init(info[:email], info[:full_name], info[:password])
    # THEN a user is created corresponding to passed arguments
    created_user = User.find_by(email: info[:email])
    assert created_user.present?
    check_user_info(created_user, info)
    check_groups(created_user, groups)
    check_roles(created_user, roles)
  end

  private

  def check_user_info(created_user, info)
    assert_equal created_user.full_name, info[:full_name]
    assert created_user.valid_password? info[:password]
    assert created_user.actif?
    assert created_user.confirmed? if info[:confirm]
  end

  def check_groups(created_user, groups)
    assert_equal created_user.groups, groups
  end

  def check_roles(created_user, roles)
    roles_sym = created_user.roles.map { |role| role.name.to_sym }
    assert_equal roles_sym, roles
  end
end
