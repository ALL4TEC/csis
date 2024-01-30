# frozen_string_literal: true

class StatisticPolicy < ApplicationPolicy
  def index?
    staff? || contact?
  end

  def update_certificate?
    staff? || contact?
  end

  def show?
    staff? || contact?
  end

  def export?
    staff? || contact?
  end

  def generate?
    staff? || contact?
  end

  class Headers < ApplicationPolicy::Headers
    private

    def member_actions
      filter_available(%i[regenerate_scoring edit])
    end

    def member_other_actions
      filter_available(%i[destroy])
    end

    def member_tabs
      %i[overview reports statistics scheduled_scans]
    end
  end
end
