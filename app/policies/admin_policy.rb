# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    not_discarded_and_admin?
  end

  def update?
    not_discarded_and_admin?
  end

  protected

  ### admin? must be overriden by childs to define what are the admin roles needed

  def discarded_and_admin?
    @record.discarded? && admin?
  end

  def not_discarded_and_admin?
    !@record.discarded? && admin?
  end
end
