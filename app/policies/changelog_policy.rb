# frozen_string_literal: true

class ChangelogPolicy < ApplicationPolicy
  def history?
    user.in_dev_process?
  end
end
