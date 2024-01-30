# frozen_string_literal: true

class ReportScanImportPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def new?
    staff?
  end

  def create?
    staff?
  end
end
