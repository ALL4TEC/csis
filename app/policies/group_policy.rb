# frozen_string_literal: true

class GroupPolicy < AdminPolicy
  include MfaPolicy

  def index?
    admin?
  end

  def users?
    admin?
  end

  def staff?
    admin?
  end

  def contact?
    admin?
  end

  def destroy?
    not_discarded_and_admin?
  end

  def restore?
    discarded_and_admin?
  end

  def add_user?
    super_admin? && !@record[:user].in_group?(@record[:group].name)
  end

  # On ne peut supprimer un user d'un groupe que s'il n'est rattaché à aucune équipe
  # et qu'il a au moins un autre groupe rattaché pour être défini comme groupe courant
  def remove_user?
    super_admin? && @record[:user].in_group?(@record[:group].name) &&
      @record[:user].group_teams(@record[:group].name).blank? &&
      @record[:user].groups.count > 1
  end

  def admin?
    if @record.is_a?(Team)
      cyber_admin?
    elsif @record.is_a?(Client)
      contact_admin?
    else
      super_admin?
    end
  end

  class Scope < SuperAdminPolicy::Scope
  end
end
