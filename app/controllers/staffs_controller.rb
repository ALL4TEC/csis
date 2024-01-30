# frozen_string_literal: true

class StaffsController < UsersController
  private

  # highest: current_user's highest priority role
  # super_admin: current_user's highest priority == 0 ?
  # himself: current_user is modifying himself
  # roles: array of role_ids for update
  # highest_change: role for update with highest priority
  def handle_params
    highest = current_user.roles.prioritized.first
    super_admin = highest.priority.zero?
    himself = current_user.id == params[:id]

    # Super_admin can modify others (not himself) has he want.
    return if super_admin && !himself

    roles = params[:staff][:role_ids] || []
    highest_change = Role.of_staffs.where(id: roles).prioritized.first

    # current_user cannot delete own highest
    roles << highest.id if himself && !highest.id.in?(roles)

    # current_user cannot delete super_admin if not super_admin himself
    if User.staffs.find(params[:id]).has_role?(:super_admin) && !himself
      roles << Role.find_by(name: :super_admin).id
    end

    # current_user cannot add super_admin if he is only cyber_admin
    if highest_change.present? && highest_change.priority.zero?
      log_suspicious(current_user, __method__, params, 'super_admin')
      roles -= [highest_change.id]
    end

    params[:staff][:role_ids] = roles
  end

  def staff_params
    params.require(:staff).permit(policy(:staff).permitted_attributes)
  end

  def staff_in_perimeter?
    true
  end
end
