# frozen_string_literal: true

class UserService
  class << self
    # Creates a user
    # @params info:
    # Hash { :email, :full_name, :password, :confirm }
    # @params groups: Array containing all groups to add user to
    # @params roles: Array containing all roles to add to user
    def add(info, groups, roles)
      user = User.create!(email: info[:email], full_name: info[:full_name],
        password: info[:password], state: :actif)
      user.confirm! if info[:confirm]
      groups.each_with_index do |group, index|
        user.current_group = group if index.zero?
        user.groups << group if index.positive?
      end
      roles.each do |role|
        user.add_role(role)
      end
      user
    end

    # Creates a user
    # linked to Staff group
    # with all staff roles
    def add_user_init(email, name, password, bypass_email_confirmation = false)
      info = {
        email: email,
        full_name: name,
        password: password,
        confirm: bypass_email_confirmation
      }
      add(info, [Group.staff], [:super_admin])
    end
  end
end
